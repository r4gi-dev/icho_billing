local function getPathValue(source, path)
    local current = source

    for segment in tostring(path):gmatch('[^.]+') do
        if type(current) ~= 'table' then
            return nil
        end

        current = current[segment]
    end

    return current
end

local function interpolate(value, params)
    if type(value) ~= 'string' or type(params) ~= 'table' then
        return value
    end

    return (value:gsub('{([%w_]+)}', function(key)
        local replacement = params[key]
        if replacement == nil then
            return '{' .. key .. '}'
        end

        return tostring(replacement)
    end))
end

function IchoBilling.T(path, params)
    local language = Config.Language or 'ja'
    local fallback = IchoBilling.Locales.en or IchoBilling.Locales.ja or {}
    local active = IchoBilling.Locales[language] or fallback
    local value = getPathValue(active, path)

    if value == nil then
        value = getPathValue(fallback, path)
    end

    if value == nil then
        return tostring(path)
    end

    return interpolate(value, params)
end
