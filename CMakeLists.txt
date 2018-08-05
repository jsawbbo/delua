cmake_minimum_required(VERSION 3.10)

# === Project ================================================================
set(CMAKE_USER_MAKE_RULES_OVERRIDE "LuaInitFlags.cmake")

set(Lua_ENABLE_CPACK OFF)
set(Lua_ENABLE_CTEST ON)

project(Luax CXX C)

get_directory_property(Luax_PARENT_DIR PARENT_DIRECTORY)

# === Version ================================================================
set(Lua_VERSION_MAJOR 5)
set(Lua_VERSION_MINOR 3)
set(Lua_VERSION_PATCH 5)

set(Lua_VERSION "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}.${Lua_VERSION_PATCH}")
set(Lua_RELEASE "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}")

message(STATUS "Lua version ${Lua_VERSION}")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${Lua_SOURCE_DIR}/cmake")

if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)
if(NOT DEFINED SCRIPT_OUTPUT_PATH)
    set(SCRIPT_OUTPUT_PATH ${Lua_BINARY_DIR}/share)
endif(NOT DEFINED SCRIPT_OUTPUT_PATH)

# === Config =================================================================
# posix features
set(LUA_USE_POSIX_INIT OFF)
if(UNIX)
    set(LUA_USE_POSIX_INIT ON)
endif(UNIX)

# dynamic load (dl) library
set(LUA_USE_DLOPEN_INIT OFF)
if(CMAKE_DL_LIBS)
    set(LUA_USE_DLOPEN_INIT ON)
endif(CMAKE_DL_LIBS)

# readline
find_library(LUA_READLINE_LIBRARY readline)
set(LUA_USE_READLINE_INIT OFF)
if(LUA_READLINE_LIBRARY)
    set(LUA_USE_READLINE_INIT ON)
endif(LUA_READLINE_LIBRARY)

# math lib
find_library(LUA_MATH_LIBRARY m)

# threads
set(CMAKE_THREAD_PREFER_PTHREAD true)
find_package(Threads)
if(Threads_FOUND)
    set(LUA_THREAD_LIBRARY Threads::Threads)
else(Threads_FOUND)
    set(LUA_THREAD_LIBRARY)
endif(Threads_FOUND)

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

if(Threads_FOUND)
    option(LUAX_THREAD_LOCKING "Enable thread-locking of the global (internal) state." ON)
else(Threads_FOUND)
    set(LUAX_THREAD_LOCKING false CACHE INTERNAL "Enable thread-locking of the global (internal) state." FORCE)
endif(Threads_FOUND)

set(LUAX_THREAD_SPROC ${CMAKE_USE_SPROC_INIT})
set(LUAX_THREAD_WIN32 ${CMAKE_USE_WIN32_THREADS_INIT})
set(LUAX_THREAD_PTHREADS ${CMAKE_USE_PTHREADS_INIT})
set(LUAX_THREAD_PTHREADS_HP ${CMAKE_HP_PTHREADS_INIT})

set(LUAX_SUFFIX "" CACHE STRING "Suffix appended to the name lua for libraries and executables.")

# === Build ==================================================================
include_directories(
    ${PROJECT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src)

add_subdirectory(cmake)
add_subdirectory(src)

# === Embedded ===============================================================
if(Luax_PARENT_DIR)
    message(STATUS "Building as sub-project (${Luax_BINARY_DIR})...")
    list(APPEND CMAKE_MODULE_PATH "${Luax_BINARY_DIR}/cmake")

    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif()
