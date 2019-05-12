#.rst:
# Simplified packaging.
# ---------------------
#
# Tools and utitilities for setting up CPack in a simplified manner.
#
# Inspired by and some code copied from
#     https://github.com/neurosuite/libneurosuite/blob/master/cmake/modules/PackNeurosuite.cmake,
#     Copyright 2015 by Florian Franzen
# 
# See 
#     https://gitlab.kitware.com/cmake/community/wikis/doc/cpack/Packaging-With-CPack
# for more information.
cmake_minimum_required(VERSION 3.10)

include(CPackSimpleNSIS)
include(CPackSimpleDMG)
include(CPackSimpleDEB)
include(CPackSimpleRPM)

include(InstallRequiredSystemLibraries)
include(CPackComponent)

set(__cpack_simple_report ON)

# === [ DEFAULTS ] ===
set(CPACK_GENERATOR "ZIP")
set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

# === [ UTILITIES ] ===
macro(cpack_simple_set outvar)
	cmake_parse_arguments(__cpack_simple_set "SIMPLE" "" "" ${ARGN})
	if(__cpack_simple_set_SIMPLE)
		set(__cpack_simple_prefix "CPACK_SIMPLE")
	else()
		set(__cpack_simple_prefix "CPACK")
	endif()

	set(${__cpack_simple_prefix}_${outvar} ${__cpack_simple_set_UNPARSED_ARGUMENTS})
	set(${__cpack_simple_prefix}_${outvar} ${__cpack_simple_set_UNPARSED_ARGUMENTS} PARENT_SCOPE)
	
	# [[ report ]]
	if(__cpack_simple_report)
		set(__cpack_simple_set_varname ${__cpack_simple_prefix}_${outvar})
		# FIXME expand to 32 characters
		
		set(__cpack_simple_set_varvalue ${${__cpack_simple_prefix}_${outvar}})
	
		if(__cpack_simple_set_SIMPLE)
			message(STATUS "[CPackSimple] ${__cpack_simple_set_varname} = ${__cpack_simple_set_varvalue}")
		else()
			message(STATUS "[CPack      ] ${__cpack_simple_set_varname} = ${__cpack_simple_set_varvalue}")
		endif()
	endif()
endmacro()

# cpack_simple_stack(<list> PUSH <element> [PARENT_SCOPE])
# cpack_simple_stack(<list> POP [PARENT_SCOPE])
# cpack_simple_stack(<list> LAST <output variable>)
macro(cpack_simple_stack listvar)
	cmake_parse_arguments(__cpack_simple_stack "PARENT_SCOPE;POP" "LAST" "PUSH" ${ARGN})
	if(__cpack_simple_stack_POP)
		list(LENGTH ${listvar} __cps_length)
		math(EXPR __cps_index "${__cps_length} - 1")
		list(REMOVE_AT ${listvar} ${__cps_index})
	elseif(__cpack_simple_stack_PUSH)
		list(APPEND ${listvar} ${__cpack_simple_stack_PUSH})
	elseif(__cpack_simple_stack_LAST)
		list(LENGTH ${listvar} __cps_length)
		math(EXPR __cps_index "${__cps_length} - 1")
		if (${__cps_index} GREATER_EQUAL 0)
			list(GET ${listvar} ${__cps_index} ${__cpack_simple_stack_LAST})
			if(__cpack_simple_stack_PARENT_SCOPE)
				set(${__cpack_simple_stack_LAST} ${${__cpack_simple_stack_LAST}} PARENT_SCOPE)
			endif()
		else()
			unset(${__cpack_simple_stack_LAST})
			if(__cpack_simple_stack_PARENT_SCOPE)
				unset(${__cpack_simple_stack_LAST} PARENT_SCOPE)
			endif()
		endif()
	endif()
	
	if(__cpack_simple_stack_PARENT_SCOPE)
		set(${listvar} ${${listvar}} PARENT_SCOPE)
	endif()
endmacro()

macro(cpack_simple_eval _result _value)
    # Copyright 2015 by Florian Franzen
    set(${_result} ${_value} ${ARGN})
endmacro()

macro(cpack_simple_read_variables _FILE_NAME _VAR_PREFIX)
    # Copyright 2015 by Florian Franzen
    file(READ "${_FILE_NAME}" contents)
    string(REGEX REPLACE ";" "\\\\;" contents "${contents}")
    string(REGEX REPLACE "\n" ";" contents "${contents}")
    foreach(line ${contents})
        string(REGEX REPLACE "=.*" "" var "${line}")
        string(REGEX REPLACE "[^=]*=" "" value "${line}")
        string(REGEX REPLACE "^\"" "" value "${value}")
        string(REGEX REPLACE "\"$" "" value "${value}")
        set(${_VAR_PREFIX}${var} "${value}")
    endforeach()
endmacro()

# === [ PARSING ] ===
macro(cpack_simple_version)
    cmake_parse_arguments(__cpack_simple_version "" "MAJOR;MINOR;PATCH" "" ${ARGN})
    if(__cpack_simple_version_MAJOR)
        if(__cpack_simple_version_UNPARSED_ARGUMENTS OR NOT __cpack_simple_version_MINOR)
            message(FATAL_ERROR "Invalid arguments passed to option `VERSION`.")
        endif()
    else()
        if(NOT __cpack_simple_version_UNPARSED_ARGUMENTS)
            message(FATAL_ERROR "Invalid arguments passed to option `VERSION`.")
        endif()
        
        string(REGEX REPLACE "^([0-9]+)\\.[0-9]+.*" "\\1" __cpack_simple_version_MAJOR ${__cpack_simple_version})
        if(__cpack_simple_version_MAJOR STREQUAL __cpack_simple_version)
            message(FATAL_ERROR "Invalid version string format (expected x.y or x.y.z).")
        endif()
        string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" __cpack_simple_version_MINOR ${__cpack_simple_version})
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" __cpack_simple_version_PATCH ${__cpack_simple_version})
        if(__cpack_simple_version_PATCH STREQUAL __cpack_simple_version)
            unset(__cpack_simple_version_PATCH)
        endif()
    endif()

    if(__cpack_simple_version_PATCH)
        set(__cpack_simple_version ${__cpack_simple_version_MAJOR}.${__cpack_simple_version_MINOR}.${__cpack_simple_version_PATCH})
    else()
        set(__cpack_simple_version ${__cpack_simple_version_MAJOR}.${__cpack_simple_version_MINOR})
    endif()
    
    cpack_simple_set(PACKAGE_VERSION ${__cpack_simple_version})
endmacro()

macro(cpack_simple_description)
    cmake_parse_arguments(__cpack_simple_description "" "FILE" "" ${ARGN})
    if(__cpack_simple_description_FILE)
        cpack_simple_set(PACKAGE_DESCRIPTION_FILE "${__cpack_simple_description_FILE}")
        # FIXME read file into CPACK_PACKAGE_DESCRIPTION?
    endif()

	if(__cpack_simple_description_UNPARSED_ARGUMENTS)    
	    cpack_simple_set(PACKAGE_DESCRIPTION "${__cpack_simple_description_UNPARSED_ARGUMENTS}")
    endif()
endmacro()

macro(cpack_simple_license)
    cmake_parse_arguments(__cpack_simple_license "" "FILE" "" ${ARGN})
    
    if(__cpack_simple_license_UNPARSED_ARGUMENTS)
        cpack_simple_set(PACKAGE_LICENSE "${__cpack_simple_license_UNPARSED_ARGUMENTS}")
    endif()
    
    if(__cpack_simple_license_FILE)
        cpack_simple_set(RESOURCE_FILE_LICENSE "${__cpack_simple_license_FILE}")        
    endif()
endmacro()

macro(cpack_simple_icon)
    cmake_parse_arguments(__cpack_simple_icon "" "INSTALL;UNINSTALL" "" ${ARGN})
    
    if(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(ICON SIMPLE "${__cpack_simple_icon_UNPARSED_ARGUMENTS}")
    endif()
    
    if(__cpack_simple_icon_INSTALL)
        cpack_simple_set(ICON_INSTALL SIMPLE "${__cpack_simple_icon_INSTALL}")
    elseif(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(ICON_INSTALL SIMPLE ${CPACK_SIMPLE_ICON})
    endif()
    
    if(__cpack_simple_icon_UNINSTALL)
        cpack_simple_set(ICON_UNINSTALL SIMPLE "${__cpack_simple_icon_UNINSTALL}")
    elseif(__cpack_simple_icon_INSTALL)
        cpack_simple_set(ICON_UNINSTALL SIMPLE ${__cpack_simple_icon_INSTALL})
    elseif(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(ICON_UNINSTALL SIMPLE ${CPACK_SIMPLE_ICON})
    endif()
endmacro()

macro(cpack_simple_url)
	cmake_parse_arguments(__cpack_simple_url "" "HOMEPAGE;ABOUT;HELP" "" ${ARGN})

	if(__cpack_simple_url_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple: invalid URL syntax.")
	endif()
	
	if(__cpack_simple_url_HOMEPAGE)
		cpack_simple_set(URL_HOMEPAGE SIMPLE ${__cpack_simple_url_HOMEPAGE})
	endif()
	
	if(__cpack_simple_url_ABOUT)
		cpack_simple_set(URL_ABOUT SIMPLE ${__cpack_simple_url_ABOUT})
	endif()
	
	if(__cpack_simple_url_HELP)
		cpack_simple_set(URL_HELP SIMPLE ${__cpack_simple_url_HELP})
	endif()
endmacro()

macro(cpack_simple_package)
	cmake_parse_arguments(__cpack_simple_package "" "GROUP" "" ${ARGN})

	if(__cpack_simple_package_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple: invalid PACKAGE syntax.")
	endif()
	
	if(__cpack_simple_package_GROUP)
		cpack_simple_set(PACKAGE_GROUP SIMPLE ${__cpack_simple_package_GROUP})
	endif()
endmacro()

set(__cpack_simple_component) # component context
macro(cpack_simple_component component)
	cmake_parse_arguments(__cpack_simple_component "COMPONENT;GROUP;PUSH;POP" "" "" ${ARGN})

	# get current context (group)
	cpack_simple_stack(__cpack_simple_component LAST __cpack_simple_context)

	# manage context
	if(__cpack_simple_component_PUSH)
		cpack_simple_stack(__cpack_simple_component PUSH ${component} PARENT_SCOPE)
	elseif(__cpack_simple_component_POP)
		cpack_simple_stack(__cpack_simple_component POP PARENT_SCOPE)
	endif()
		
	if(NOT __cpack_simple_component_POP)
		# add component or add group?
		set(__component ON)
		if(__cpack_simple_component_GROUP)
			set(__component OFF)
		endif()
		
		if(__component)
		# === add component
		#cpack_add_component(compname
		#                    [DISPLAY_NAME name]
		#                    [DESCRIPTION description]
		#                    [HIDDEN | REQUIRED | DISABLED ]
		#                    [DEPENDS comp1 comp2 ... ]
		#                    [INSTALL_TYPES type1 type2 ... ]
		#                    [DOWNLOADED]
		#                    [ARCHIVE_FILE filename])
			if(__cpack_simple_context)
				cpack_add_component(${component} ${ARGN} GROUP ${__cpack_simple_context})
			else()
				cpack_add_component(${component} ${ARGN})
			endif()
			
			# [[ report ]]
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] Adding component ${component}")
			endif()
		else()
		# === add component group
		#cpack_add_component_group(groupname
		#                         [DISPLAY_NAME name]
		#                         [DESCRIPTION description]
		#                         [EXPANDED]
		#                         [BOLD_TITLE])
			if(__cpack_simple_context)
				cpack_add_component_group(${component} ${ARGN} PARENT_GROUP ${__cpack_simple_context})
			else()
				cpack_add_component_group(${component} ${ARGN})
			endif()
	
			# [[ report ]]
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] Adding component group ${component}")
			endif()
		endif()
	endif()
endmacro()

# === [ CONFIGURATION ] ===
function(CPackSimple)
	# ROOT
	cmake_parse_arguments(_ "" "NAME;CONTACT;VENDOR;SUMMARY;ICON" "VERSION;DESCRIPTION;LICENSE;URL;PACKAGE;COMPONENTS" ${ARGN})
	
	# ===[CPack] NAME, VENDOR, CONTACT, SUMMARY
    if(NOT __NAME)
        string(TOLOWER ${PROJECT_NAME}  __NAME)
        message(AUTHOR_WARNING "CPackSimple: NAME is set from PACKAGE_NAME (${PACKAGE_NAME}).")
    endif()

    if(NOT __VENDOR)
        set(__VENDOR ${PROJECT_NAME})
        message(AUTHOR_WARNING "CPackSimple: VENDOR is set from PACKAGE_NAME (${PACKAGE_NAME}).")
    endif()

    if(NOT __CONTACT)
        message(FATAL_ERROR "CPackSimple: CONTACT is required.")
    endif()

    if(NOT __SUMMARY)
        message(FATAL_ERROR "CPackSimple: SUMMARY is required.")
    endif()
    
    cpack_simple_set(PACKAGE_NAME ${__NAME})
    cpack_simple_set(PACKAGE_VENDOR "${__VENDOR}")
    cpack_simple_set(PACKAGE_CONTACT "${__CONTACT}")
    cpack_simple_set(PACKAGE_DESCRIPTION_SUMMARY "${__SUMMARY}")

    # ===[CPack] VERSION
    if(__VERSION)
	    cpack_simple_version(${__VERSION})
    else()
	    cpack_simple_version( 
		    MAJOR ${PROJECT_VERSION_MAJOR}
		    MINOR ${PROJECT_VERSION_MINOR}
		    PATCH ${PROJECT_VERSION_PATCH})
    endif()

	# ===[CPack] DESCRIPTION
    if(__DESCRIPTION)
	    cpack_simple_description(${__DESCRIPTION})
    endif()

	# ===[CPack] LICENSE
    if(__LICENSE)
	    cpack_simple_license(${__LICENSE})
    endif()

	# === [Simple] ICON, URL
	if(__ICON)
		cpack_simple_icon(${__ICON})
	endif()
	
	if(__URL)
		cpack_simple_url(${__URL})
	endif()
	
	# === [Simple] PACKAGE
	if(__PACKAGE)
		cpack_simple_package(${__PACKAGE})
	endif(__PACKAGE)
	
	# === [Simple] COMPONENTS
	if(__COMPONENTS)
		CPackSimpleComponent(${__COMPONENTS})
	endif(__COMPONENTS)
endfunction()

# === [ COMPONENTS ] ===
function(CPackSimpleComponent)
	set(__group)   # component or group block
	set(__decl)    # group or component declaration arguments 
	set(__level 0) # BEGIN-END block depth
	
	# sanity check
	foreach(arg ${ARGN})
		if(arg STREQUAL BEGIN)
			math(EXPR __level "${__level} + 1")
		elseif(arg STREQUAL END)
			math(EXPR __level "${__level} - 1")
		endif()
	endforeach()
	if(NOT ${__level} EQUAL 0)
		message(FATAL_ERROR "CPackSimple: unbalance BEGIN/END in component declaration.")
	endif()
	
	# parse and sort arguments
	foreach(arg ${ARGN})
		if(arg STREQUAL BEGIN)
			# book keeping
			math(EXPR __level "${__level} + 1")
			if(__level GREATER 1)
				list(APPEND __group ${arg})
			endif()
		elseif(arg STREQUAL END)
			# book keeping
			math(EXPR __level "${__level} - 1")
			
			# return to 0?
			if(__level EQUAL 0)
				# parse declaration
				if(NOT "${__decl}" STREQUAL "")
					cpack_simple_component(${__decl} PUSH)
				endif()

				# recurse
				CPackSimpleComponent(${__group})
			
				# finish
				if(NOT "${__decl}" STREQUAL "")
					cpack_simple_component(${__decl} POP)
				endif()
				set(__group)
				set(__decl)
			else()
				list(APPEND __group ${arg})
			endif()
		elseif(__level EQUAL 0)
			# add to declaration
			list(APPEND __decl ${arg})
		else()
			list(APPEND __group ${arg})
		endif()
	endforeach()

	# parse declaration
	if(NOT "${__decl}" STREQUAL "")
		cpack_simple_component(${__decl})
	endif()
endfunction()

# === [ PACKAGING ] ===
function(CPackSimplePackage)
	cmake_parse_arguments(__cpack_simple_package "NSIS;DMG;DEB;RPM" "" "")
	
	if(__cpack_simple_package_NSIS)
		CPackSimpleDefineNSIS(${ARGN})
	elseif(__cpack_simple_package_DMG)
		CPackSimpleDefineDMG(${ARGN})
	elseif(__cpack_simple_package_DEB)
		CPackSimpleDefineDEB(${ARGN})
	elseif(__cpack_simple_package_RPM)
		CPackSimpleDefineRPM(${ARGN})
	endif()
endfunction()


