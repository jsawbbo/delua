cmake_minimum_required(VERSION 3.17)

set(CMAKE_MESSAGE_LOG_LEVEL TRACE)

# === Project ================================================================
include("DeLuaInitFlags.cmake")
include(CMyke/Init OPTIONAL)
project(DeLua 
    VERSION 5.4.0.4
    LANGUAGES CXX C)

get_directory_property(DeLua_PARENT_DIR PARENT_DIRECTORY)
include(CMyke/Paths OPTIONAL)

# === Version ================================================================
set(DeLua_VERSION "${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR}.${DeLua_VERSION_PATCH}")
set(DeLua_RELEASE "${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR}")
set(DeLua_RELEASE_SUFFIX "${DeLua_VERSION_MAJOR}${DeLua_VERSION_MINOR}")

math(EXPR DeLua_VERSION_NUM "${DeLua_VERSION_MAJOR}*100 + ${DeLua_VERSION_MINOR}")

message(STATUS "DeLua version ${DeLua_VERSION}")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${DeLua_SOURCE_DIR}/cmake")

if(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
endif(NOT DEFINED EXECUTABLE_OUTPUT_PATH)
if(NOT DEFINED LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
endif(NOT DEFINED LIBRARY_OUTPUT_PATH)
if(NOT DEFINED SCRIPT_OUTPUT_PATH)
    set(SCRIPT_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
endif(NOT DEFINED SCRIPT_OUTPUT_PATH)

# === Config =================================================================
# defaults
set(LUA_COMPAT_5_3_INIT OFF)
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

include(target/luaconf.cmake)

# === Installation ===========================================================
include(DeLuaPaths)

# script and library path
delua_path_to_dir(DeLua_PATH_DIR "${LUA_LDIR}")
delua_path_to_dir(DeLua_CPATH_DIR "${LUA_CDIR}")

# === Build ==================================================================
# include directory
if(${LUA_NAME} STREQUAL "lua")
	set(DeLua_HEADER_DIR include)
else()
	set(DeLua_HEADER_DIR include/${LUA_NAME})
endif()

# sub-directories
add_subdirectory(cmake)
add_subdirectory(target)

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
    DESTINATION  share/doc/delua/${DeLua_RELEASE}
    COMPONENT "documentation")    

install(FILES lua/README
    DESTINATION  share/doc/delua/${DeLua_RELEASE}/lua
    COMPONENT "documentation")    

install(DIRECTORY lua/doc
    DESTINATION  share/doc/delua/${DeLua_RELEASE}/lua
    COMPONENT "documentation")

# === Package ================================================================
if(NOT DeLua_PARENT_DIR AND CMYKE_FOUND)
include(CMyke/Package OPTIONAL)

cmyke_package(
    NAME "delua-${DeLua_RELEASE}"
    CONTACT "Jürgen 'George' Sawinski <george@caesar.de>"
    VENDOR "Research center caesar"
    SUMMARY "Simple, extensible, embeddable programming language."
    DESCRIPTION 
"This is Lua 5.4.0, released on 29 Jun 2020.

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
        FILE ${DeLua_SOURCE_DIR}/LICENSE
        
    URL
		HOMEPAGE "https://bitbucket.org/jsaw/delua"
		ABOUT    "https://www.lua.org/about.html"
		HELP     "https://www.lua.org/docs.html"
        
    ICON         "${DeLua_SOURCE_DIR}/lua/doc/logo.gif"
    
    PACKAGE
	    CATEGORY "Interpreter"

	COMPONENTS
		COMPONENT runtime
			DEFAULT
			INSTALL YES
			DISPLAY_NAME "Runtime"
			BEGIN
				# sub-component....
			END
			
		COMPONENT common-development
			INSTALL NO
		    DISPLAY_NAME "Common development files"
		    DEPENDS runtime
			BEGIN
				GROUP something
				DISPLAY_NAME Something
			END
			
		COMPONENT development
			INSTALL NO
		    DISPLAY_NAME "Development files"
		    DEPENDS runtime common-development
			
		COMPONENT documentation
		    INSTALL NO
		    DISPLAY_NAME "Documentation"
		    DEPENDS runtime
)

#cmyke_package(NSIS
#)
#
#cmyke_package(DMG
#)
#
#cmyke_package(RPM
#)

#cmyke_package(DEB
#	RELEASE "0"
#)

cmyke_package(DEB DISTRIBUTION Ubuntu
	MAINTAINER "Juergen \"George\" Sawinski <juergen.sawinski@gmail.com>"	

	RELEASE "${DeLua_VERSION_TWEAK}"
	Ubuntu_RELEASE 0
	
	COMPONENTS
		COMPONENT runtime 
			SUFFIX OFF
			RECOMMENDS documentation
			
		COMPONENT common-development 
			NAME delua-common
			SUFFIX OFF
			ARCHITECTURE all
				
		COMPONENT development 
			SUFFIX dev
			DEPENDS common-development
			RECOMMENDS documentation
					
		COMPONENT documentation
			SUFFIX doc
)

include(CPack)
endif()

include(CMyke/Finish OPTIONAL)

