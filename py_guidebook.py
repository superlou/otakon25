import json
import pickle
from datetime import datetime, timedelta
import copy
# Required for https://stackoverflow.com/questions/32245560/module-object-has-no-attribute-strptime-with-several-threads-python
import time
import traceback
import requests
from pytz import utc

class Guidebook:
    def __init__(self, api_key):
        self.API_KEY = api_key
    
    def headers(self):
        return {
            "Authorization": "JWT " + self.API_KEY
        }

    def get_json(self, url, params=None):
        response = requests.get(url, params=params, headers=self.headers())
        print(response.url)
        return response.json()

    def get_guides(self):
        URL = "https://builder.guidebook.com/open-api/v1.1/guides/"
        rsp = self.get_json(URL)
        return rsp
    
    def get_sessions(self, guide_id=None, ordering="start_time"):
        url = "https://builder.guidebook.com/open-api/v1.1/sessions/"
        params = {
            "guide": guide_id,
            # "ordering": ordering,
        }
        
        sessions = []
        response = self.get_json(url, params)
        sessions += response["results"]
        next_url = response["next"]

        while next_url:
            response = self.get_json(next_url)
            sessions += response["results"]
            next_url = response["next"]
        
        # Guidebook cannot reliably sort by start_times. It will
        # return duplicate IDs across different request/response pages
        # and miss some sessions.
        sessions.sort(key=lambda s: s["start_time"])

        return sessions
    
    def get_locations(self, guide_id=None):
        url = "https://builder.guidebook.com/open-api/v1.1/locations/"
        params = {
            "guide": guide_id
        }

        locations = []
        response = self.get_json(url, params)
        locations += response["results"]
        next_url = response["next"]

        while next_url:
            response = self.get_json(next_url)
            locations += response["results"]
            next_url = response["next"]
        
        return locations

    def get_schedule_tracks(self, guide_id=None):
        url = "https://builder.guidebook.com/open-api/v1.1/schedule-tracks/"
        params = {
            "guide": guide_id
        }

        schedule_tracks = []
        response = self.get_json(url, params)
        schedule_tracks += response["results"]
        next_url = response["next"]

        while next_url:
            response = self.get_json(next_url)
            schedule_tracks += response["results"]
            next_url = response["next"]
        
        return schedule_tracks


def build_session_list(guidebook, guide_id, local_tz, session_rename_map, location_rename_map):
    locations = guidebook.get_locations(guide_id)
    location_map = {location["id"]: location["name"] for location in locations}

    schedule_tracks = guidebook.get_schedule_tracks(guide_id)
    schedule_track_map = {track["id"]: track["name"] for track in schedule_tracks}

    sessions = guidebook.get_sessions(guide_id)
    
    # All times from Guidebook are in UTC and get converted to local time
    def prepare_timestamp(text):
        timestamp = datetime.strptime(text, GUIDEBOOK_TIMESTAMP_FMT)
        return utc.localize(timestamp).astimezone(local_tz)

    sessions = [{
        "id": session["id"],
        "name": session_rename_map.get(session["id"], session["name"]),
        "start": prepare_timestamp(session["start_time"]),
        "finish": prepare_timestamp(session["end_time"]),
        "locations": [location_rename_map.get(loc_id, location_map[loc_id]) 
                      for loc_id in session["locations"]],
        "tracks": [schedule_track_map[track_id] for track_id in session["schedule_tracks"]]
    } for session in sessions]

    return sessions


GUIDEBOOK_TIMESTAMP_FMT = "%Y-%m-%dT%H:%M:%S.%f+0000"


def load_sessions_pickle(filename):
    try:
        return pickle.load(open(filename, "rb"))
    except Exception:
        traceback.print_exc()
        return []


def send_update(node, updating, checks, desc, exception=None):
    node.send_json("/guidebook/update", {
        "updating": updating,
        "checks": checks,
        "desc": desc,
        "exception": str(exception),
    })


UNKNOWN = 0
OK = 1
IN_PROGRESS = 2
FAIL = 3

checks = {
    "fetch": UNKNOWN,
    "process": UNKNOWN,
    "write": UNKNOWN,
    "cache": UNKNOWN,
}

def rename_field_to_dict(field):
    lines = field.split("\n")
    m = {}

    for line in lines:
        parts = line.split(",")
        if len(parts) >= 2:
            try:
                id = int(parts[0].strip())
                name = parts[1]
                m[id] = name.strip()
            except Exception as exc:
                print(exc)

    return m


def update_guidebook_data(node, api_key, guide_id, now, local_tz,
                          all_day_threshold, is_soon_threshold,
                          scratch_dir,
                          session_rename_field, location_rename_field):
    global checks
    checks = {
        "fetch": UNKNOWN,
        "process": UNKNOWN,
        "write": UNKNOWN,
        "cache": UNKNOWN,
    }

    session_rename_map = rename_field_to_dict(session_rename_field)
    location_rename_map = rename_field_to_dict(location_rename_field)

    # Attempt to get data from Guidebook, and fall back to saved data
    # if not successful.
    try:
        checks["fetch"] = IN_PROGRESS
        send_update(node, True, checks, "Fetching from Guidebook")
        guidebook = Guidebook(api_key)
        sessions = build_session_list(guidebook, guide_id, local_tz, session_rename_map, location_rename_map)
        checks["fetch"] = OK
        send_update(node, True, checks, "Fetched successfully")
    except Exception as e:
        checks["fetch"] = FAIL
        send_update(node, True, checks, "Failed fetching from Guidebook, processing local data", e)
        sessions = load_sessions_pickle(scratch_dir + "/data_guidebook.pkl")

    # Make a copy so that we can later cache Guidebook data without the metadata
    cache_data = copy.deepcopy(sessions)

    try:
        checks["process"] = IN_PROGRESS
        send_update(node, True, checks, "Processing Guidebook data")
        add_session_metadata(sessions, now, is_soon_threshold)
        time.sleep(0.1)
        checks["process"] = OK
        send_update(node, True, checks, "Done processing Guidebook data")
    except Exception as e:
        checks["process"] = FAIL
        send_update(node, False, checks, "Failed processing Guidebook data", e)
        return

    try:
        checks["write"] = IN_PROGRESS
        send_update(node, True, checks, "Writing session info to JSON")
        write_sessions_now(sessions, now, all_day_threshold)
        write_sessions_soon(sessions, now, all_day_threshold)
        write_sessions_all_day(sessions, now, all_day_threshold)
        time.sleep(0.1)
        checks["write"] = OK
        send_update(node, True, checks, "Done writing session info to JSON")
    except Exception as e:
        checks["write"] = FAIL
        send_update(node, False, checks, "Failed writing session info to JSON", e)
        return

    # Only cache Guidebook data if *everything* is successful. If there is something
    # in a fetch that causes exceptions, we don't want to use that data next time.
    try:
        checks["cache"] = IN_PROGRESS
        send_update(node, True, checks, "Caching Guidebook data")
        pickle.dump(cache_data, open(scratch_dir + "/data_guidebook.pkl", "wb"), 2)
        time.sleep(0.1)
        checks["cache"] = OK
        send_update(node, False, checks, "Done caching Guidebook data")
    except Exception as e:
        checks["cache"] = FAIL
        send_update(node, False, checks, "Failed caching Guidebook data", e)


def starts_today(now, start):
    # A "day" starts at 4 am
    today_start = now.replace(hour=4, minute=0, second=0, microsecond=0)
    if now.hour < 4:
        # Before 4 am, treat the previous day as the start
        today_start -= timedelta(hours=24)

    today_finish = today_start + timedelta(hours=24)

    return today_start <= start < today_finish


def completed_fraction(now, start, duration):
    completed_sec = (now - start).total_seconds()
    duration_sec = duration.total_seconds()

    if duration_sec > 0:
        return max(min(completed_sec / duration_sec, 1.0), 0.0)
    else:
        return 1.0    


def add_session_metadata(sessions, now, is_soon_timedelta):
    """ Add information that is used repeatedly"""
    for session in sessions:
        start = session["start"]
        finish = session["finish"]
        session["duration"] = finish - start
        session["completed_fraction"] = completed_fraction(now, start, session["duration"])
        session["is_open"] = now >= start and now <= finish
        session["is_before_start"] = now < start
        session["is_after_finish"] = now > finish
        session["is_soon"] = start > now and start <= (now + is_soon_timedelta)
        session["starts_today"] = starts_today(now, start)


def save_sessions_for_topic_list(sessions, filename):
    session_data = [{
        "start_hhmm": datetime.strftime(session["start"], "%I:%M").lstrip("0"),
        "start_ampm": datetime.strftime(session["start"], "%P"),
        "finish_hhmm": datetime.strftime(session["finish"], "%I:%M").lstrip("0"),
        "finish_ampm": datetime.strftime(session["finish"], "%P"),
        "completed_fraction": session["completed_fraction"],
        "is_open": session["is_open"],
        "is_before_start": session["is_before_start"],
        "is_after_finish": session["is_after_finish"],
        "id": session["id"],
        "name": session["name"],
        "locations": session["locations"],
        "tracks": session["tracks"],
    } for session in sessions]

    with open(filename, "w") as f:
        json.dump(session_data, f)


def write_sessions_now(sessions, now, max_duration):
    sessions_now = [
        s for s in sessions
        if s["is_open"]
    ]

    save_sessions_for_topic_list(sessions_now, "data_sessions_now.json")


def write_sessions_soon(sessions, now, max_duration):
    sessions_soon = [
        s for s in sessions
        if s["is_soon"]
    ]

    save_sessions_for_topic_list(sessions_soon, "data_sessions_soon.json")


def write_sessions_all_day(sessions, now, min_duration):
    sessions_all_day = [
        s for s in sessions
        if s["starts_today"] and s["duration"] > min_duration
    ]

    save_sessions_for_topic_list(sessions_all_day, "data_sessions_all_day.json")
