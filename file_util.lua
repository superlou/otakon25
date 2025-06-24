function file_load_safe(filename, default)
    local ok, text = pcall(function() return resource.load_file(filename) end)

    if ok then
        return text
    else
        return default
    end
end