cmake_minimum_required(VERSION 3.10)

# === Project ================================================================
set(CMAKE_USER_MAKE_RULES_OVERRIDE "LuaInitFlags.cmake")

set(Lua_ENABLE_CPACK OFF)
set(Lua_ENABLE_CTEST ON)

project(Lua C;CXX)

# === Version ================================================================
set(Lua_VERSION_MAJOR 5)
set(Lua_VERSION_MINOR 3)
set(Lua_VERSION_PATCH 5)

set(Lua_VERSION "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}.${Lua_VERSION_PATCH}")
set(Lua_RELEASE "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}")

message("Configured Lua ${Lua_VERSION}")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${Lua_SOURCE_DIR}/cmake")

if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)

# === Config =================================================================
set(LUA_USE_POSIX_INIT OFF)
if(UNIX)
    set(LUA_USE_POSIX_INIT ON)
endif(UNIX)

set(LUA_USE_DLOPEN_INIT OFF)
if(CMAKE_DL_LIBS)
    set(LUA_USE_DLOPEN_INIT ON)
endif(CMAKE_DL_LIBS)

find_library(LUA_READLINE_LIBRARY readline)
set(LUA_USE_READLINE_INIT OFF)
if(LUA_READLINE_LIBRARY)
    set(LUA_USE_READLINE_INIT ON)
endif(LUA_READLINE_LIBRARY)

find_library(LUA_MATH_LIBRARY m)

# === Options ================================================================
# lua
option(LUA_32BITS "Enable 32-bit integers and 32-bit floats (default: auto-detected)." OFF)
option(LUA_USE_C89 "Use of ISO-C89 features only." OFF)
option(LUA_USE_POSIX "Use Posix features." ${LUA_USE_POSIX_INIT})
option(LUA_USE_DLOPEN "Use dlopen (requires dl library, auto-detected)." ${LUA_USE_DLOPEN_INIT})
option(LUA_USE_READLINE "Use readline features (requires readline library, auto-detected)." ${LUA_USE_READLINE_INIT})

set(LUA_ROOT "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Root installation path.")

#FIXME there are more options in luaconf.h.in that should be added here

# extensions
option(LUAX_EXCEPTION_ENABLE "Enable C++ exceptions." ON)
set(LUAX_EXCEPTION_THROW "lua::except(L,(c)->status)" CACHE STRING "Exception to throw.")

# === Build ==================================================================
include_directories(
    ${PROJECT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src)

add_subdirectory(cmake)
add_subdirectory(src)

