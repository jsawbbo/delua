# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.
#
# This file is partially copied from FindLua.cmake.

#.rst:
# FindDelua
# ---------
#
#
#
# Locate Lua library built using Delua (https://bitbucket.org/jsaw/delua).
# This module defines
#
# ::
#
#
#   LUA_FOUND          - if false, do not try to link to Lua
#   LUA_LIBRARIES      - both lua and lualib
#   LUA_INCLUDE_DIR    - where to find lua.h
#   LUA_VERSION_STRING - the version of Lua found
#   LUA_VERSION_MAJOR  - the major version of Lua
#   LUA_VERSION_MINOR  - the minor version of Lua
#   LUA_VERSION_PATCH  - the patch version of Lua
#
#
#
# Note that the expected include convention is
#
# ::
#
#   #include "lua.h"
#
# and not
#
# ::
#
#   #include <lua/lua.h>
#
# This is because, the lua location is not standardized and may exist in
# locations other than lua/

if(Delua_FIND_VERSION_MAJOR AND NOT Delua_FIND_VERSION_MINOR)
    message("Version major and minor are required.")
endif()

if(Delua_FIND_VERSION_MAJOR AND Delua_FIND_VERSION_PATCH)
    message(AUTHOR_WARNING "Patch version ignored.")
endif()

include(DeluaConfig-${Delua_FIND_VERSION_MAJOR}.${Delua_FIND_VERSION_MINOR}
    OPTIONAL RESULT_VARIABLE DeluaConfig_FOUND)
