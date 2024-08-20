cmake_minimum_required(VERSION 3.22)

# === Project ================================================================
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DeLuaInitFlags.cmake")
include(${CMAKE_CURRENT_SOURCE_DIR}/Version.cmake)

set(MY_INSTALL_STYLE System)

include(.myake/devel.cmake OPTIONAL)

find_package(Myake QUIET)
project(DeLua 
    VERSION ${Lua_VERSION}.${DeLua_VERSION_TWEAK}
    LANGUAGES CXX C)

get_directory_property(DeLua_PARENT_DIR PARENT_DIRECTORY)

# === Version ================================================================
set(DeLua_VERSION ${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR}.${DeLua_VERSION_PATCH})
set(DeLua_RELEASE ${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})

math(EXPR DeLua_VERSION_NUM "${DeLua_VERSION_MAJOR}*100 + ${DeLua_VERSION_MINOR}")

message(STATUS "Lua version ${Lua_VERSION} [${DeLua_VERSION_TWEAK}]")

# === CMake Paths ============================================================
list(INSERT CMAKE_MODULE_PATH 0 "${DeLua_SOURCE_DIR}/cmake")

set(DeLua_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${DeLua_OUTPUT_PATH})
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${DeLua_OUTPUT_PATH})
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)
if(NOT DEFINED SCRIPT_OUTPUT_PATH)
    set(SCRIPT_OUTPUT_PATH ${DeLua_OUTPUT_PATH})
endif(NOT DEFINED SCRIPT_OUTPUT_PATH)

# === Compiler ===============================================================

# === Dependencies ===========================================================

# readline (not in config, because only relevant for the interpreter)
find_library(LUA_READLINE_LIBRARY readline)
if(LUA_READLINE_LIBRARY MATCHES NOTFOUND)
	unset(LUA_READLINE_LIBRARY CACHE)
else()
	add_definitions(-DLUA_USE_READLINE)

    if(NOT DEFINED LUA_USE_TABCOMPLETION_INIT)
        set(LUA_USE_TABCOMPLETION_INIT ON)
    endif()
    set(LUA_USE_TABCOMPLETION ${LUA_USE_TABCOMPLETION_INIT} CACHE STRING "Use simple tab-completion when the readline library is available.")
    if(LUA_USE_TABCOMPLETION)
        add_definitions(-DLUA_USE_TABCOMPLETION)
    endif()
endif()

# math lib
find_library(LUA_MATH_LIBRARY m)
if(NOT LUA_MATH_LIBRARY MATCHES NOTFOUND)
	link_libraries(${LUA_MATH_LIBRARY})
endif()

# === Config =================================================================
# defaults
set(LUA_COMPAT_5_3_INIT OFF)
set(LUA_32BITS_INIT OFF)
set(LUA_USE_C89_INIT OFF)

# system features
if(WINDOWS AND NOT UNIX)
    if(NOT DEFINED LUA_USE_C89_INIT)
        set(LUA_USE_C89_INIT OFF)
    endif(NOT DEFINED LUA_USE_C89_INIT)
    set(LUA_USE_WINDOWS true CACHE INTERNAL "Visual Studio compat." FORCE)
    set(LUA_DL_DLL true CACHE INTERNAL "Windows DLL support.")
elseif(APPLE)
    set(LUA_USE_MACOSX true CACHE INTERNAL "MacOSX compat." FORCE)
endif()

# posix features
set(LUA_USE_POSIX_INIT OFF)
if(UNIX)
    set(LUA_USE_POSIX_INIT ON)
endif(UNIX)

# dynamic load (dl) library
set(LUA_USE_DLOPEN_INIT OFF)
if(CMAKE_DL_LIBS)
    set(LUA_USE_DLOPEN_INIT ON)
endif()

# paths
set(LUA_ROOT_INIT "${CMAKE_INSTALL_PREFIX}")

# build options
set(LUA_PROGNAME "${LUA_PROGNAME_INIT}" CACHE STRING "The name used for libraries and executables (lib\${LUA_PROGNAME} etc.).")

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

include(target/luaconf.cmake)

# === Installation ===========================================================

# script and library path
set(DeLua_PATH_DIR "${LUA_LDIR}")
set(DeLua_CPATH_DIR "${LUA_CDIR}")

# installation paths
if(UNIX AND NOT WINDOWS)
    include(GNUInstallDirs)
    
    set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/delua-${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})
else()
    set(CMAKE_INSTALL_DOCDIR doc/delua-${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})
endif()

set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
list(APPEND CMAKE_INSTALL_RPATH ${LUA_ROOT}${CMAKE_INSTALL_LIBDIR}/)

# === Build ==================================================================
# include directory
set(DeLua_HEADER_DIR include/${LUA_PROGNAME})

# sub-directories
add_subdirectory(cmake)
add_subdirectory(target)
add_subdirectory(modules)

# === Embedded ===============================================================
if(DeLua_PARENT_DIR)
    message(STATUS "Building as sub-project (${DeLua_BINARY_DIR})...")
    list(APPEND CMAKE_MODULE_PATH "${DeLua_BINARY_DIR}/cmake")
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif(DeLua_PARENT_DIR)

# === Resources ==============================================================

install(FILES target/lua.png
    DESTINATION  share/icons
    RENAME lua${DeLua_RELEASE_SUFFIX}.png
    COMPONENT "runtime")

# === Documentation ==========================================================

install(FILES README.md
    DESTINATION  ${CMAKE_INSTALL_DOCDIR}
    COMPONENT "documentation")    

install(FILES lua/README
    DESTINATION  ${CMAKE_INSTALL_DOCDIR}/lua
    COMPONENT "documentation")    

install(DIRECTORY lua/doc
    DESTINATION  ${CMAKE_INSTALL_DOCDIR}/lua
    COMPONENT "documentation")

# === Package ================================================================
if(NOT DeLua_PARENT_DIR AND Myake_FOUND)
	include(DeLuaPackaging.cmake)
endif()

include(My/Lists OPTIONAL)
