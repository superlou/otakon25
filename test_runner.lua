require "test_table_util"
require "test_sessions_filter"
require "table_util"

function test_runner()
    print("[Test] Starting tests...")
    for val in pairs(_G) do
        if string_starts_with(val, "test_") and val ~= "test_runner" then
            local test_report = "[Test] Running " .. val .. "..."
            local ok, res = xpcall(_G[val], debug.traceback)
            if ok then
                test_report = test_report .. "pass."
                print(test_report)
            else
                test_report = test_report .. "FAIL."
                print(test_report)
                print(res)
            end
        end
    end
    print("[Test] Tests done.")
end

return test_runner