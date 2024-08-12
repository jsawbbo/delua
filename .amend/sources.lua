#!sources <directory> -- Copy original Lua sources into project tree.

assert(fs.exists(OPTIONS[1]), "invalid source path")
message("Copying Lua sources from %q...", OPTIONS[1])

local srcdir = OPTIONS[1]
local dstdir = fs.concat(fs.currentdir(), "lua")

-- copy files recursively
function copy_r(src)
    fs.dodir(fs.concat(srcdir, src), function(item)
        if item[2]:len() > 0 and item[2] ~= src then
            if item.attr.mode == 'file' then
                local infile = src and fs.concat(src, item[2]) or item[2]
                local outfile = infile
                if item[2] == 'luaconf.h' then
                    outfile = outfile .. ".orig"
                end

                if not fs.exists(fs.concat(dstdir, outfile)) then
                    message("new source: %s", infile)
                end

                local out<close> = io.open(fs.concat(dstdir, outfile), "w+")
                local txt = io.readall(fs.concat(srcdir, infile))
                out:write(txt)
            elseif item.attr.mode == 'directory' then
                copy_r(item[2])
            else
                error("encountered unknown mode: " .. item.attr.mode)
            end
        end
    end, {})
end
copy_r()

-- extract version
message("Extracting version information...")
local readme = io.readall(fs.concat(srcdir, "README"))
local ver, date = readme:match("Lua ([0-9.]+), released on ([^.]+).")

local modified = (PROJECT.VERSION ~= ver) or (PROJECT.DATE ~= date)
modified = true

PROJECT.VERSION = ver
PROJECT.DATE = date
PROJECT.TWEAK = modified and 1 or PROJECT.TWEAK
PROJECT.UPDATE = modified
amend_project_update()

-- update Version.cmake
if modified then
    local out<close> = io.open("Version.cmake", "w+")
    out:write(string.format([[
set(Lua_VERSION %s)
set(Lua_DATE %q)

set(DeLua_VERSION_TWEAK %d)        
]], ver, date, PROJECT.TWEAK))
end

-- update README.md
if modified then
    local readme = io.readall("README.md")
    readme = readme:gsub("This is Lua [0-9.]+, released on [^.]+[.]",
        "This is Lua " .. ver .. ", released on " .. date .. " (see file *lua/README*).")
    local out<close> = io.open("README.md", "w+")
    out:write(readme)
end
