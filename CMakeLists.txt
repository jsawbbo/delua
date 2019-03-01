cmake_minimum_required(VERSION 3.10)

# === Project ================================================================
set(CMAKE_USER_MAKE_RULES_OVERRIDE "LuaInitFlags.cmake")

project(Lua 
    VERSION 5.3.5
    LANGUAGES CXX C)

get_directory_property(Lua_PARENT_DIR PARENT_DIRECTORY)

# === Version ================================================================
set(Lua_VERSION "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}.${Lua_VERSION_PATCH}")
set(Lua_RELEASE "${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}")

message(STATUS "Lua version ${Lua_VERSION}")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${Lua_SOURCE_DIR}/cmake")

# single library and executable output path
if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${Lua_BINARY_DIR}/bin)
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)

# script output path
if(NOT DEFINED SCRIPT_OUTPUT_PATH)
    set(SCRIPT_OUTPUT_PATH ${Lua_BINARY_DIR}/share)
endif(NOT DEFINED SCRIPT_OUTPUT_PATH)

# === Config =================================================================
# defaults
set(LUA_32BITS_INIT OFF)
set(LUA_USE_C89_INIT OFF)

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

#    # threads
#    set(CMAKE_THREAD_PREFER_PTHREAD true)
#    find_package(Threads)
#    if(Threads_FOUND)
#        set(LUA_THREAD_LIBRARY Threads::Threads)
#    else(Threads_FOUND)
#        set(LUA_THREAD_LIBRARY)
#    endif(Threads_FOUND)

# paths
set(LUA_ROOT_INIT "${CMAKE_INSTALL_PREFIX}")

# build options
set(LUA_NAME "${LUA_NAME_INIT}" CACHE STRING "The name used for libraries and executables (lib${LUA_NAME} etc.).")

set(LUA_LANGUAGE_C "${LUA_LANGUAGE_C_INIT}" CACHE STRING "Compile C library.")
set(LUA_LANGUAGE_CXX "${LUA_LANGUAGE_CXX_INIT}" CACHE STRING "Compile C++ libraries.")

option(LUA_BUILD_STATIC "Build static library." ${LUA_BUILD_STATIC_INIT})
option(LUA_BUILD_SHARED "Build shared library." ${LUA_BUILD_SHARED_INIT})

set(LUA_BUILD_INTERPRETER ${LUA_BUILD_INTERPRETER_INIT} CACHE BOOL "Build interpreter executable.")
if(NOT LUA_LANGUAGE_C AND LUA_BUILD_INTERPRETER) 
    message(WARNING "Building interpreter depends on the C-library, disabling.")
    set(LUA_BUILD_INTERPRETER OFF CACHE BOOL "Build interpreter executable." FORCE)
endif()

set(LUA_BUILD_COMPILER ${LUA_BUILD_COMPILER_INIT} CACHE BOOL "Build compiler executable.")
if(NOT LUA_LANGUAGE_C AND LUA_BUILD_COMPILER) 
    message(WARNING "Building compiler depends on the C-library, disabling.")
    set(LUA_BUILD_COMPILER OFF CACHE BOOL "Build compiler executable." FORCE)
endif()

# === Build ==================================================================
add_subdirectory(cmake)
add_subdirectory(build)

# === Package ================================================================
include(CPackUtils)

CPackInit(
    CONTACT "Jürgen \"George\" Sawinski <juergen.sawinski@caesar.de>"
    VENDOR "Research center caesar."
    SUMMARY "Simple, extensible, embeddable programming language."
    DESCRIPTION_FILE ${PROJECT_SOURCE_DIR}/README.md
    LICENSE_FILE ${PROJECT_SOURCE_DIR}/LICENSE
)

CPackSet(
    HOMEPAGE     "https://bitbucket.org/jsaw/giralua"
    ABOUT_URL    "https://bitbucket.org/jsaw/giralua"
    HELP_URL     "https://bitbucket.org/jsaw/giralua"
    GROUP        "Interpreter"
)

CPackDefineNSIS(
)

CPackDefineDMG()

CPackDefineDEB("Debian"
    # FIXME
)

CPackDefineDEB("Ubuntu"
    # FIXME
)

CPackDefineRPM("Fedora"
    # FIXME
)

CPackDefineRPM("Scientific"
    # FIXME
)

include(CPack)

# === Embedded ===============================================================
if(Lua_PARENT_DIR)
    message(STATUS "Building as sub-project (${Luax_BINARY_DIR})...")
    list(APPEND CMAKE_MODULE_PATH "${Lua_BINARY_DIR}/cmake")
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif(Lua_PARENT_DIR)
