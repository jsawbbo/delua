local pam = require 'pamlib'

local brief = "DeLua Package Manager"
local version = pam._VERSION
local copyright = [[
Copyright (C) 2024 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany
]]
local license_short = "MIT"
local license = [[
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local sformat = string.format
local stdout = io.stdout
local stderr = io.stderr
local function printf(fmt, ...)
    stdout:write(sformat(fmt, ...))
end
local log = require 'pam.log'

local def -- option definition table

local function showopts(def)
    for _, t in ipairs(def) do
        local brief = assert(t.brief, "brief is required")

        local opt
        if t.short then
            opt = '-' .. t.short
        end
        if t.long then
            if opt then
                opt = opt .. ',' .. '--' .. t.long
            else
                opt = '--' .. t.long
            end
        end

        if t.value then
            if t.optional then
                opt = opt .. '[=<' .. t.value .. '>]'
                brief = sformat("%s (default: %s)", brief, tostring(t.default))
            else
                opt = opt .. '=<' .. t.value .. '>'
            end
        end

        printf("    %-25s %s\n", opt, brief)
    end
end

local function usage(cmd)
    printf("%s %s\n", brief, version)
    printf("%s", copyright)
    printf("License: %s\n", license_short)
    printf("    %s\n", (def[cmd] or def).usage)

    if not cmd then
        local cmds = def.cmds
        if #cmds > 0 then
            printf("\nCommands:\n")
            for _, k in ipairs(cmds) do
                local t = def[k]
                if (#cmds == 1) or not t.hidden then
                    printf("    %-25s %s\n", k, t.brief)
                end
            end
        end
    else
        if def[cmd].description then
            printf("%s", def[cmd].description)
        end
    end

    printf("\nOptions:\n")
    showopts(def)

    if cmd then
        printf("\nCommand options:\n")
        showopts(def[cmd])
    end

    os.exit()
end

def = {
    cmds = {},
    usage = "pam <options> [<command> [<command-options>...]]",
    {
        long = 'help',
        short = 'h',
        brief = 'show usage information',
        callback = usage
    },
    {
        long = 'version',
        short = 'V',
        brief = 'display version information',
        callback = function()
            print(pam._VERSION)
        end
    },
    {
        long = 'verbose',
        short = 'v',
        brief = 'increase or set verbosity',
        value = 'string',
        default = 'notice',
        optional = 'true',
        callback = function(value)
            if value then
                if value == 'help' then
                    print("Available verbosity levels:")
                    for _,k in ipairs(log.severity) do
                        print("", k)
                    end
                    os.exit()
                end
                if not log.severity[value] then
                    log.fatal("Verbosity level %q is not known. Use --verbose=help to get a list.", value)
                end
                log.level = log.severity[value]
            else
                log.level = log.level + 1
            end
        end
    }    
}

--- Register a command.
-- @param
--     cmd              The command name.
--     optsdef          The options definition.
-- 
-- Option definition:
--    callback = <command-function>,
--    usage = "<usage pattern>",
--    brief = "<brief description>",
--    description = [===[ long description ]===],
--    hidden = <boolean>,
--    { 
--        long = "<long-option>",
--        short = "<short-option>",
--        brief = "<short-description>"
--        value = "<value-type>",
--        optional = <value-is-optional (boolean)>,
--        default = "<default-value>",
--        callback = <function>
--    }, ...
function pam.register(cmd, optsdef)
    assert(def[cmd] == nil, "Command '" .. tostring(cmd) .. "' already declared.")

    def[cmd] = optsdef;
    tinsert(def.cmds, cmd)
end

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

-- Create a "link" table for options
local lnk = {}
local function preparedef(optsdef)
    for _, t in ipairs(optsdef) do
        assert(t.name or t.long, "either 'long' or 'name' must be given")
        assert(t.long or t.short, "one of 'short' or 'long' must be set")

        if not t.name then
            t.name = t.long:gsub("[^a-z]+", "_")
        end

        if t.long then
            assert(lnk[t.long] == nil, "long option '" .. t.long .. "' already declared")
            lnk[t.long] = t
        end

        if t.short then
            assert(lnk[t.short] == nil, "short option '" .. t.short .. "' already declared")
            lnk[t.short] = t
        end

        if t.default then
            t.value = t.value or math.type(t.default) or type(t.default)
        end
    end
end

local function opterror(fmt, ...)
    stderr:write(sformat(fmt, ...), '\n')
    os.exit(1)
end

local function optparse(v, argt, cmd, opts)
    if v:sub(2,2) ~= '-' then
        -- short
        for i = 2,v:len() do
            local key = v:sub(i,i)
            local t = lnk[key]
            if not t then
                opterror("Option '-%s' is not recognized. Use `--help` for further information.", key)
            end

            if t.callback then
                t.callback(cmd)
            else
                opts[key] = true
            end
        end
    else
        -- long 
        local key, value = v:match("[-][-]?([^=]+)(.*)")
        if value:len() == 0 then
            value = nil
        else
            value = value:sub(2, -1) -- remove '='
        end

        local t = lnk[key]
        if not t then
            opterror("Option '%s' is not recognized. Use `--help` for further information.", v)
        end

        if t.callback then
            t.callback(value or t.default or cmd)
        else
            if t.value then
                value = value or t.default
                if not value and not t.optional then
                    opterror("Option '%s' requires an options value. Use `--help` for further information.", v)
                end
                opts[key] = to(value, t.value)
            else
                opts[key] = true
            end
        end
    end

    tremove(argt, 1)
end

--- Parse and process command-line arguments.
-- @param 
--      ...         Command-line arguments.
function pam.process(...)
    local cmd
    local opts = {}
    preparedef(def)

    local t = {...}
    while #t > 0 do
        local v = t[1]
        if v:sub(1, 1) == '-' then
            optparse(v, t, cmd, opts)
        else
            if cmd == nil then
                cmd = v
                if not def[cmd] then
                    opterror("Command '%s' is not recognized. Use `pam --help` for further information.", cmd)
                end
                preparedef(def[cmd])
            else
                tinsert(opts, v)
            end
            tremove(t, 1)
        end
    end

    if cmd then
        def[cmd].callback(opts)
    end
end

return pam
