cmake_minimum_required(VERSION 3.10)

# === Project ================================================================
set(CMAKE_USER_MAKE_RULES_OVERRIDE "LuaInitFlags.cmake")

set(Lua_ENABLE_CPACK OFF)
set(Lua_ENABLE_CTEST ON)

project(Lua C CXX)

# === Version ================================================================
set(Lua_VERSION_MAJOR 0)
set(Lua_VERSION_MINOR 0)
set(Lua_VERSION_PATCH 0)

set(Lua_VERSION "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}.${Lua_VERSION_PATCH}")
set(Lua_RELEASE "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${Lua_SOURCE_DIR}/cmake")

if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)

# === Options ================================================================

# === Build ==================================================================
add_subdirectory(cmake)
#add_subdirectory(src)

