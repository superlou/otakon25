from datetime import datetime, timedelta
import time
from pytz import utc, timezone


class Clockwork:
    def __init__(self, local_tz, debug_datetime_text, debug_accel):
        self.local_tz = local_tz
        self.system_tz = self.find_system_tz()
        self.debug_accel = debug_accel
        self.startup_time = self._local_time()
        self.debug_datetime = None

        try:
            fmt = '%Y-%m-%dT%H:%M:%S'
            now = datetime.strptime(debug_datetime_text, fmt)
            self.debug_datetime = self.local_tz.localize(now)
        except Exception:
            pass

    def find_system_tz(self):
        is_dst = time.localtime().tm_isdst
        tzname = time.tzname[is_dst]
        return timezone(tzname)

    def _local_time(self):
        now = datetime.now()

        if self.system_tz == utc:
            # We are probably on a Raspberry Pi and need to get to local time
            now = utc.localize(now).astimezone(self.local_tz)
        else:
            now = self.system_tz.localize(now)
        
        return now

    def _debug_time(self):
        now = self.debug_datetime      
        offset = self._local_time() - self.startup_time
        accel_offset = timedelta(seconds=offset.total_seconds() * self.debug_accel)
        now += accel_offset
        return now

    def now_local(self):
        if self.debug_datetime is None:
            return self._local_time()
        else:
            return self._debug_time()


def update_time(node, now):
    time_hhmm = now.strftime("%I:%M")
    time_am_pm = now.strftime("%p")
    month = now.strftime("%b")
    
    date = now.strftime("%d")
    if date[0] == "0":
        date = date[1]

    # Used for compatiblity since "%-I" doesn't work on all systems
    if time_hhmm[0] == "0":
        time_hhmm = time_hhmm[1:]

    node.send_json("/clock/update", {
        "hh_mm": time_hhmm,
        "am_pm": time_am_pm,
        "month": month,
        "date": date
    })
