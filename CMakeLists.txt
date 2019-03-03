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

# paths
set(LUA_ROOT_INIT "${CMAKE_INSTALL_PREFIX}/")

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

include(build/luaconf.cmake)
# === Build ==================================================================
add_subdirectory(cmake)
add_subdirectory(build)

# === Embedded ===============================================================
if(Lua_PARENT_DIR)
    message(STATUS "Building as sub-project (${Luax_BINARY_DIR})...")
    list(APPEND CMAKE_MODULE_PATH "${Lua_BINARY_DIR}/cmake")
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif(Lua_PARENT_DIR)

# === Resources ==============================================================

install(FILES build/lua.png
    DESTINATION  share/icons
    RENAME lua${Lua_VERSION_MAJOR}${Lua_VERSION_MINOR}.png
    COMPONENT "runtime")

# === Documentation ==========================================================

install(FILES README.md
    DESTINATION  share/doc/delua/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}
    COMPONENT documentation)    

install(FILES lua/README
    DESTINATION  share/doc/delua/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}/lua
    COMPONENT documentation)    

install(DIRECTORY lua/doc
    DESTINATION  share/doc/delua/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}/lua
    COMPONENT documentation)    

# === Package ================================================================
if(NOT Lua_PARENT_DIR)
include(CPackUtils)

CPackSetup(
    NAME "delua-${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}"
    CONTACT "Jürgen 'George' Sawinski <george@caesar.de>"
    VENDOR "Research center caesar."
    SUMMARY "Simple, extensible, embeddable programming language."
    DESCRIPTION 
"This is Lua 5.3.5, released on 26 Jun 2018.

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the cmake'ified Lua source (http://www.lua.org) source. It can be used 
to build Lua binaries and packages on all major operating systems, but may be 
also embedded in other projects.

No major code changes have been made to the original Lua sources (except the  
handling of the search path) and the supplement of exceptions when building  
a C++ version of the libraries."
    LICENSE "MIT"
        FILE ${Lua_SOURCE_DIR}/LICENSE
)

CPackCommon(
    HOMEPAGE     "https://bitbucket.org/jsaw/delua"
    ABOUT_URL    "https://www.lua.org/about.html"
    HELP_URL     "https://www.lua.org/docs.html"
    
    GROUP        "Interpreter"
    
    ICON         "${Lua_SOURCE_DIR}/lua/doc/logo.gif"
)

CPackComponents(ALL runtime development documentation)

CPackComponents(runtime DEFAULT
    INSTALL YES
    DISPLAY_NAME "Runtime"
)

CPackComponents(development
    INSTALL NO
    PACKAGE_SUFFIX dev
    DISPLAY_NAME "Development headers"
    DEPENDS runtime
)

CPackComponents(documentation
    INSTALL NO
    PACKAGE_SUFFIX doc
    DISPLAY_NAME "Documentation"
)

###

#CPackDefineNSIS(
#)

#CPackDefineDMG(
#)

CPackDefineDEB("Debian"
    SECTION "Interpreter"    
    # FIXME
)

set(ubuntu_debian_version "0")
set(ubuntu_package_release "0")
CPackDefineDEB("Ubuntu"
    TEMPLATE "\${NAME}_\${VERSION}-${ubuntu_debian_version}ubuntu${ubuntu_package_release}_\${ARCHITECTURE}"
    RECOMMENDS "delua-${Lua_VERSION_MAJOR}.${LUA_VERSOIN_MINOR}-doc"
    # FIXME
)

#CPackDefineRPM("Fedora"
#    # FIXME
#)

#CPackDefineRPM("Scientific"
#    # FIXME
#)

#macro(gen_cpack_suse _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("openSUSE.*"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                         "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")
#endmacro()
#
#macro(gen_cpack_fedora _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("Fedora"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                         "\${NAME}-\${VERSION}.fc\${RELEASE}.\${ARCHITECTURE}")
#endmacro()
#
#macro(gen_cpack_scientific _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("Scientific"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                        "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")

include(CPack)
endif()
