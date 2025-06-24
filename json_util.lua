local json = require "json"

-- Helper because util.json_watch is not available in the open source version
function json_watch(filename, handler)
    util.file_watch(filename, function(content)
        local json_content = json.decode(content)
        handler(json_content)
    end)
end