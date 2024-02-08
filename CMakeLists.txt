cmake_minimum_required(VERSION 3.22)

# set(CMAKE_MESSAGE_LOG_LEVEL TRACE)

# === Project ================================================================
include(${CMAKE_CURRENT_SOURCE_DIR}/DeLuaInitFlags.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/Version.cmake)

find_package(CMyke QUIET)
include(My/Init OPTIONAL)
project(DeLua 
    VERSION ${Lua_VERSION}.${DeLua_VERSION_TWEAK}
    LANGUAGES CXX C)

include(My/Config OPTIONAL)
get_directory_property(DeLua_PARENT_DIR PARENT_DIRECTORY)

# === Version ================================================================
set(DeLua_VERSION ${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR}.${DeLua_VERSION_PATCH})
set(DeLua_RELEASE ${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})

math(EXPR DeLua_VERSION_NUM "${DeLua_VERSION_MAJOR}*100 + ${DeLua_VERSION_MINOR}")

message(STATUS "Lua version ${Lua_VERSION} [${DeLua_VERSION_TWEAK}]")

# === CMake Paths ============================================================
list(APPEND CMAKE_MODULE_PATH "${DeLua_SOURCE_DIR}/cmake")

# === Compiler ===============================================================

# === Dependencies ===========================================================

# readline
find_library(LUA_READLINE_LIBRARY readline)
if(LUA_READLINE_LIBRARY MATCHES NOTFOUND)
	unset(LUA_READLINE_LIBRARY CACHE)
else()
	# not in config, because only relevant for the interpreter
	add_definitions(-DLUA_USE_READLINE)
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
set(LUA_ROOT_INIT "${CMAKE_INSTALL_PREFIX}/")

# build options
set(LUA_NAME "${LUA_NAME_INIT}" CACHE STRING "The name used for libraries and executables (lib\${LUA_NAME} etc.).")

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
# output
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

# include directory
set(DeLua_HEADER_DIR include/${LUA_NAME})

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
if(NOT DeLua_PARENT_DIR AND CMyke_FOUND)
include(My/Package)

my_package(
	ARCHITECTURE all
    NAME "delua-${DeLua_RELEASE}"
    CONTACT "Jürgen 'George' Sawinski <juergen.sawinski@mpinb.mpg.de>"
    VENDOR "MPI f. Neurobiol. of Behavior — caesar, Bonn, Germany"
    DESCRIPTION {
		SUMMARY "Simple, extensible, embeddable programming language."
		FULL "\
This is Lua ${Lua_VERSION}, released on ${Lua_Date}.

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the CMake'ified version of the Lua (http://www.lua.org) sources. It may 
be used to build Lua binaries and packages on all major operating systems, or can 
be embedded in other projects.

Minor adaptions to the original Lua sources (such as handling of the search path) 
were made, and, a C++ interface (using exceptions) was added. For a full list of
modifications, see: https://github.com/jsawbbo/delua
"
	}

    LICENSE "MIT" {
        FILE ${DeLua_SOURCE_DIR}/LICENSE
	}

    URL {
		HOMEPAGE "https://github.com/jsawbbo/delua"
		ABOUT    "https://www.lua.org/about.html"
		HELP     "https://www.lua.org/docs.html"
	}

    ICON         "${DeLua_SOURCE_DIR}/lua/doc/logo.gif"
    
    # PACKAGE {
	#     CATEGORY "Interpreter"
	# }

	# COMPONENTS
	# 	COMPONENT runtime
	# 		DEFAULT
	# 		INSTALL YES
	# 		DISPLAY_NAME "Runtime"
	# 		BEGIN
	# 			# sub-component....
	# 		END
			
	# 	COMPONENT common-development
	# 		INSTALL NO
	# 	    DISPLAY_NAME "Common development files"
	# 	    DEPENDS runtime
	# 		BEGIN
	# 			GROUP something
	# 			DISPLAY_NAME Something
	# 		END
			
	# 	COMPONENT development
	# 		INSTALL NO
	# 	    DISPLAY_NAME "Development files"
	# 	    DEPENDS runtime common-development
			
	# 	COMPONENT documentation
	# 	    INSTALL NO
	# 	    DISPLAY_NAME "Documentation"
	# 	    DEPENDS runtime
)

#my_package(NSIS
#)
#
#my_package(DMG
#)
#
#my_package(RPM
#)

#my_package(DEB
#	RELEASE "0"
#)

my_package(DEB DISTRIBUTION Ubuntu
	MAINTAINER "Juergen \"George\" Sawinski <juergen.sawinski@gmail.com>"	

	RELEASE "${DeLua_VERSION_TWEAK}ubuntu0"
	
	# COMPONENTS {
	# 	COMPONENT runtime 
	# 		SUFFIX OFF
	# 		RECOMMENDS documentation
			
	# 	COMPONENT common-development 
	# 		NAME delua-common
	# 		SUFFIX OFF
	# 		ARCHITECTURE all
				
	# 	COMPONENT development 
	# 		SUFFIX dev
	# 		DEPENDS common-development
	# 		RECOMMENDS documentation
					
	# 	COMPONENT documentation
	# 		SUFFIX doc
	# }
)

include(CPack)
endif()

include(My/Lists OPTIONAL)

