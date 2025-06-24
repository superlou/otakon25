require "test_lib"
require "table_util"

function test_array_contains()
    local a = {"cat", "dog", "horse"} 
    assert_true(array_contains(a, "dog"))
    assert_false(array_contains(a, "fox"))
end

function test_string_split()
    assert_equal_table(
        iter_to_table(string_split("a,b,c", ",")),
        {"a", "b", "c"}
    )
    assert_equal_table(
        iter_to_table(string_split("room 1, room 2, room3", ",")),
        {"room 1", " room 2", " room3"}
    )
    assert_equal_table(
        iter_to_table(string_split("room 1", ",")),
        {"room 1"}
    )
end

function test_string_strip()
    assert_equal(string_strip("  apples  "), "apples")
    assert_equal(string_strip("  room 2  "), "room 2")
    assert_equal(string_strip(" \t tab string \t"), "tab string")
end

function shallow_copy(t)
    local new_table = {}
    for k,v in pairs(t) do
        new_table[k] = v
    end
    return new_table
end