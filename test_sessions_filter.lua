require "sessions_filter"

local test_sessions = {
    {
        is_after_finish = false,
        locations = { "Panel 2 (WEWCC 146B)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Literature and Likeness in Bungo Stray Dogs",
        completed_fraction = 0,
        is_before_start = true,
    },
    {
        is_after_finish = false,
        locations = { "Panel 4 (WEWCC 150)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Not Your Average Family: Best Non-Parent Parental Figures in Anime",
        completed_fraction = 0,
        is_before_start = true,
    },
    {
        is_after_finish = false,
        locations = { "Panel 6 (WEWCC 151B)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Doll Shopping in Japan",
        completed_fraction = 0,
        is_before_start = true,
    },
    {
        is_after_finish = false,
        locations = { "Panel 1 (WEWCC 207)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Guest", "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Q&A with TRIGGER's President and Animators [G]",
        completed_fraction = 0,
        is_before_start = true,
    },
    {
        is_after_finish = false,
        locations = { "Panel 7 (WEWCC 152)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Guest", "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Shinji Aramaki on Bubblegum, Bikes, and Bungie [G]",
        completed_fraction = 0,
        is_before_start = true,
    },
    {
        is_after_finish = false,
        locations = { "Panel 5 (WEWCC 151A)" },
        start_ampm = "am", start_hhmm = "10:15",
        is_open = false,
        tracks = { "Panel" },
        finish_hhmm = "11:15", finish_ampm = "am",
        name = "Otome Games: We Love Our Cartoon Boyfriends",
        completed_fraction = 0,
        is_before_start = true,
    },
}

function test_sessions_filter_locations()
    local sessions = {
        {locations={"room a"}, tracks={"video"}},
        {locations={"room b"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room d", "room e"}, tracks={"live"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room a"}})
    assert_equal(#result, 1)
    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room b"}})
    assert_equal(#result, 1)
    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room c"}})
    assert_equal(#result, 2)
    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room b", "room c"}})
    assert_equal(#result, 3)
    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room b", "room c", "room x"}})
    assert_equal(#result, 3)
    local result = sessions_filter(shallow_copy(sessions), {filter_locations={"room a", "room b", "room c", "room x"}})
    assert_equal(#result, 4)

    local result1 = sessions_filter(shallow_copy(sessions), {filter_locations={"room d"}})
    local result2 = sessions_filter(shallow_copy(sessions), {filter_locations={"room e"}})
    assert_equal_table(result1, result2)
end

function test_sessions_filter_tracks()
    local sessions = {
        {locations={"room a"}, tracks={"video"}},
        {locations={"room b"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {filter_tracks={"video"}})
    assert_equal(#result, 2)
    local result = sessions_filter(shallow_copy(sessions), {filter_tracks={"live"}})
    assert_equal(#result, 4)
    local result = sessions_filter(shallow_copy(sessions), {filter_tracks={"live", "video"}})
    assert_equal(#result, 5)
    local result = sessions_filter(shallow_copy(sessions), {filter_tracks={"video", "live"}})
    assert_equal(#result, 5)
end

function test_sessions_exclude_tracks()
    local sessions = {
        {locations={"room a"}, tracks={"video"}},
        {locations={"room b"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {exclude_tracks={"video"}})
    assert_equal(#result, 3)
    local result = sessions_filter(shallow_copy(sessions), {exclude_tracks={"live"}})
    assert_equal(#result, 1)
    local result = sessions_filter(shallow_copy(sessions), {exclude_tracks={"live", "video"}})
    assert_equal(#result, 0)
    local result = sessions_filter(shallow_copy(sessions), {exclude_tracks=nil})
    assert_equal(#result, 5)
end

function test_sessions_filter_ids()
    local sessions = {
        {id=1, locations={"room a"}, tracks={"video"}},
        {id=2, locations={"room b"}, tracks={"live"}},
        {id=3, locations={"room b"}, tracks={"live"}},
        {id=4, locations={"room c"}, tracks={"live"}},
        {id=5, locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {filter_ids={1}})
    assert_equal(#result, 1)
    local result = sessions_filter(shallow_copy(sessions), {filter_ids={1, 3, 5}})
    assert_equal(#result, 3)
    local result = sessions_filter(shallow_copy(sessions), {filter_ids=nil})
    assert_equal(#result, 5)
end

function test_sessions_exclude_ids()
    local sessions = {
        {id=1, locations={"room a"}, tracks={"video"}},
        {id=2, locations={"room b"}, tracks={"live"}},
        {id=3, locations={"room b"}, tracks={"live"}},
        {id=4, locations={"room c"}, tracks={"live"}},
        {id=5, locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {exclude_ids={1}})
    assert_equal(#result, 4)
    local result = sessions_filter(shallow_copy(sessions), {exclude_ids={1, 3, 5}})
    assert_equal(#result, 2)
    local result = sessions_filter(shallow_copy(sessions), {exclude_ids=nil})
    assert_equal(#result, 5)
end

function test_sessions_exclude_closed()
    local sessions = {
        {id=1, locations={"room a"}, tracks={"video"}, is_after_finish=true},
        {id=2, locations={"room b"}, tracks={"live"}, is_after_finish=true},
        {id=3, locations={"room b"}, tracks={"live"}, is_after_finish=false},
        {id=4, locations={"room c"}, tracks={"live"}, is_after_finish=true},
        {id=5, locations={"room d", "room e"}, tracks={"live", "video"}, is_after_finish=false},
    }

    local result = sessions_filter(shallow_copy(sessions), {exclude_closed=nil})
    assert_equal(#result, 5)
    local result = sessions_filter(shallow_copy(sessions), {exclude_closed=false})
    assert_equal(#result, 5)
    local result = sessions_filter(shallow_copy(sessions), {exclude_closed=true})
    assert_equal(#result, 2)
end

function test_sessions_include_id()
    local sessions = {
        {id=1, locations={"room a"}, tracks={"video"}},
        {id=2, locations={"room b"}, tracks={"live"}},
        {id=3, locations={"room b"}, tracks={"live"}},
        {id=4, locations={"room c"}, tracks={"live"}},
        {id=5, locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {
        filter_tracks={"video"},
        include_ids={3, 4}
    })
    assert_equal(#result, 4)

    local result = sessions_filter(shallow_copy(sessions), {
        filter_locations={"room a"},
        include_ids={3, 4}
    })
    assert_equal(#result, 3)

    local result = sessions_filter(shallow_copy(sessions), {
        filter_ids={2, 3},
        include_ids={5}
    })
    assert_equal(#result, 3)

    local result = sessions_filter(shallow_copy(sessions), {
        exclude_tracks={"video"},
        include_ids={5}
    })
    assert_equal(#result, 4)

    local result = sessions_filter(shallow_copy(sessions), {
        exclude_ids={1, 2, 3},
        include_ids={3}
    })
    assert_equal(#result, 3)
end

function test_sessions_filter_multiple()
    local sessions = {
        {locations={"room a"}, tracks={"video"}},
        {locations={"room b"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room c"}, tracks={"live"}},
        {locations={"room d", "room e"}, tracks={"live", "video"}},
    }

    local result = sessions_filter(shallow_copy(sessions), {
        filter_locations={"room a", "room b"},
        filter_tracks={"video"}
    })
    assert_equal(#result, 1)

    local result = sessions_filter(shallow_copy(sessions), {
        filter_locations={"room d"},
        filter_tracks={"live"}
    })
    assert_equal(#result, 1)

    local result = sessions_filter(shallow_copy(sessions), {
        filter_locations={"room a", "room b", "room c", "room d"},
        filter_tracks={"live"}
    })
    assert_equal(#result, 4)

    local result = sessions_filter(shallow_copy(sessions), {
        filter_locations={"room a", "room b", "room c", "room d"},
        filter_tracks={"live", "video"}
    })
    assert_equal(#result, 5)
end

function test_sessions_filter_real_data()
    local sessions = shallow_copy(test_sessions)
    local result = sessions_filter(sessions, {filter_locations={"Panel 7 (WEWCC 152)"}})
    assert_equal(#result, 1)
end

function test_extract_session_filters_from_config()
    local text = "!session-list\n" ..
                 "filter-location:Room A, Room B, Room C\n" ..
                 "filter-track:Track A, Track B\n" ..
                 "filter-id:123,456\n" ..
                 "exclude-track:Track C, Track D\n" ..
                 "exclude-id:789,111\n" ..
                 "exclude-closed:true\n" ..
                 "include-id:222, 333\n"

    local filters = extract_session_filters_from_config(text)
    assert_equal_table(filters.filter_locations, {"Room A", "Room B", "Room C"})
    assert_equal_table(filters.filter_tracks, {"Track A", "Track B"})
    assert_equal_table(filters.filter_ids, {123, 456})
    assert_equal_table(filters.exclude_tracks, {"Track C", "Track D"})
    assert_equal_table(filters.exclude_ids, {789, 111})
    assert_equal_table(filters.exclude_closed, true)
    assert_equal_table(filters.include_ids, {222, 333})
end