-- DeLua Package Manager - command line argument parsing
-- Copyright (C) 2024 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany
-- 
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
local pam = require 'pamlib'

local tinsert = table.insert
local tremove = table.remove
local sformat = string.format
local errorfmt = function(fmt, ...)
    error(sformat(fmt, ...), 2)
end

local defaultdef = {
    {
        long = 'help',
        short = 'h',
        brief = 'show usage information'
    },
    usage = [[
]]
}

local function tointeger(v)
    local res = tonumber(v)
    if math.type(res) ~= 'integer' then
        return nil, "not an integer"
    end
end

local function toboolean(v)
    if type(v) == 'boolean' then
        return v
    elseif type(v) == 'number' then
        local res = tointeger(v)
        if res == nil then
            return nil
        end
        return res ~= 0
    elseif type(v) == 'string' then
        if v == 'true' then
            return true
        elseif v == 'false' then
            return false
        else
            return nil
        end
    else
        return nil
    end
end

local function to(v, T)
    if T == 'boolean' then
        return toboolean(v)
    elseif T == 'integer' then
        return tointeger(v)
    elseif T == 'number' then
        return tonumber(v)
    elseif (T == 'string') or (T == nil) then
        return tostring(v)
    end
end

--- Show usage.
local function usage(def)
    local function printf(fmt, ...)
        io.stdout:write(sformat(fmt, ...))
    end

    if def.usage then
        printf(def.usage)
    else
        printf([====[
DeLua Package Manager %s
Copyright (C) 2024 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany

Usage:
        pam <options> [<command> [<command-options>...]]
]====], pam._VERSION)
    end

    if def.commands then
        printf("\nCommands:\n")
        for _, v in ipairs(def.commands) do
            printf("    %-20s %s\n", v.name, v.brief)
        end
    end

    printf("\nOptions:\n")
    for _, v in ipairs(def) do
        local opt = ""
        if v.short then
            opt = opt .. '-' .. v.short
            if v.long then
                opt = opt .. ','
            end
        end
        if v.long then
            opt = opt .. '--' .. v.long
        end

        if v.value then
            if v.default then
                opt = opt .. '[=<' .. v.value .. '>]'
            else
                opt = opt .. '=<' .. v.value .. '>'
            end
        end

        local brief = v.brief
        if v.default then
            brief = sformat('%s (default: %s)', brief, tostring(v.default))
        end

        printf("   %-20s %s\n", opt, brief)
    end
end

--- Parse command-line arguments.
-- @param 
--      def         Definition.
--      ...         Command-line arguments.
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- Option entries:
--    { 
--        long = "<long-option>",
--        short = "<short-option>",
--        brief = "<short-description>"
--        value = "<value-type>",
--        default = "<default-value>",
--        callback = <function>
--    } 
function pam.parseopts(def, ...)
    local args = {}
    local opts = {}
    package.loaded['pam.options'] = nil -- FIXME debugging

    -- prepare def table
    for i, v in ipairs(defaultdef) do
        tinsert(def, i, v)
    end
    for i, v in ipairs(def) do
        assert(v.long or v.name, "'long' or 'name' is required in definition table entry " .. tostring(i))
        assert(v.long or v.short, "at least 'long' or 'short' is required in definition table entry " .. tostring(i))

        if v.long then
            v.name = v.name or v.long:gsub("[^a-z]", "_")
            def[v.long] = def[i]
        end

        if v.short then
            def[v.short] = def[i]
        end

        if v.default then
            v.value = v.value or math.type(v.default) or type(v.default)
        end
    end

    -- parse
    local t = {...}
    while #t > 0 do
        local v = t[1]
        if v:sub(1, 1) == '-' then
            if v:sub(2, 2) == '-' then
                local key, value = v:match("[-][-]([^=]+)(.*)")
                if not def[key] then
                    errorfmt("Option %s is not recognized. Use --help for usage information.", v)
                end

                if value:len() == 0 then
                    value = v.default
                else
                    value = value:sub(2, -1)
                end

                local T = def[key].value
                if T then
                    if not value then
                        errorfmt("Options %s requires an argument.", v)
                    end
                    value = to(value, def[key].value)
                    if not value then
                        errorfmt("Options %s requires a(n) %s as argument.", T)
                    end
                else
                    if value then
                        errorfmt("Options %s does not have an argument.", v)
                    end
                    value = true
                end
                opts[key] = value
            else
                v = v:sub(2, -1)
            end
            tremove(t, 1)
        else
            tinsert(args, v)
            tremove(t, 1)
        end
    end

    if opts.help then
        usage(def)
    end

    if true then
        print("Options:")
        for k,v in pairs(opts) do
            print("", k, v)
        end

        print("Arguments:")
        for i,v in ipairs(args) do
            print("", v)
        end
    end

    return args, opts
end

return pam
