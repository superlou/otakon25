-- From https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
function filter_inplace(arr, func)
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

function split_every_n(array, n)
    local result = {}

    local current_page_index = 1
    local current_page = {}

    for i = 1, #array do
        if #current_page == n then
            table.insert(result, current_page)
            current_page = {}
        end

        table.insert(current_page, array[i])
    end

    if #current_page > 0 then
        table.insert(result, current_page)
    end

    return result
end

-- https://stackoverflow.com/questions/11669926/is-there-a-lua-equivalent-of-scalas-map-or-cs-select-function
function map_table(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function map_iter(iter, f)
    local t = {}
    for v in iter do
        t[#t + 1] = f(v)
    end
    return t
end

function array_contains(array, value)
    for _, item_value in ipairs(array) do
        if item_value == value then return true end
    end
    return false
end

function string_split(str, delimiter)
    return string.gmatch(str, "[^,]+")
end

function string_strip(str)
    return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

function string_starts_with(str, start)
    return str:sub(1, #start) == start
end

function string_ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function iter_to_table(...)
    local arr = {}
    for v in ... do
      arr[#arr + 1] = v
    end
    return arr
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function pprint(o)
    print(dump(o))
end