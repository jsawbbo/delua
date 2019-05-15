include(CPackComponent)

macro(cpack_simple_configure_components)
	set(__cscc_decl)

	set(__cscc_wait_begin ON)
	set(__cscc_group 0)

	foreach(__cscc_arg ${ARGN})
		if(__cscc_wait_begin)
			if(NOT __cscc_arg STREQUAL BEGIN)
				message(FATAL_ERROR "CPackSimple - in components declaration: expected a BEGIN statement.")
			endif()
			
			set(__cscc_wait_begin OFF)
			set(__cscc_group 1)
		else()
			if(__cscc_arg STREQUAL BEGIN)
				math(EXPR __cscc_group "${__cscc_group} + 1")
			elseif(__cscc_arg STREQUAL END)
				math(EXPR __cscc_group "${__cscc_group} - 1")
			endif()

			if(__cscc_group GREATER 0)
				list(APPEND __cscc_decl ${__cscc_arg})
			else()
				cpack_simple_parse_component(${__cscc_decl})

				set(__cscc_wait_begin ON)
				set(__cscc_group 0)
				set(__cscc_decl)
			endif()
		endif()
	endforeach()
	
	if(__cscc_wait_end)
		message(FATAL_ERROR "CPackSimple - in components declaration: unbalanced BEGIN-END block.")
	endif()
endmacro()

set(__cpack_add_component_OPT "HIDDEN;REQUIRED;DISABLED;DOWNLOADED")
set(__cpack_add_component_ONE "DISPLAY_NAME;DESCRIPTION;ARCHIVE_FILE;PLIST")
set(__cpack_add_component_MULTI "DEPENDS;INSTALL_TYPES")
macro(cpack_simple_add_component compname)
#	cpack_add_component(compname
#                    [DISPLAY_NAME name]
#                    [DESCRIPTION description]
#                    [HIDDEN | REQUIRED | DISABLED ]
#                    [GROUP group]
#                    [DEPENDS comp1 comp2 ... ]
#                    [INSTALL_TYPES type1 type2 ... ]
#                    [DOWNLOADED]
#                    [ARCHIVE_FILE filename]
#                    [PLIST filename])
	cmake_parse_arguments(__csac "${__cpack_add_component_OPT};DEFAULT" "${__cpack_add_component_ONE};PARENT;INSTALL;PACKAGE_SUFFIX" "${__cpack_add_component_MULTI}" ${ARGN})
	
	if(__csac_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple - invalid arguments passed to cpack_simple_add_component: ${__csac_UNPARSED_ARGUMENTS}")
	endif()
	
	# re-generate arguments for cpack_add_component
	set(__csac_add_args)
	foreach(k ${__cpack_add_component_OPT})
		if(DEFINED __csac_${k} AND __csac_${k})
			list(APPEND __csac_add_args ${k})
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] CPACK_COMPONENT_${compname}_${k} = TRUE")
			endif()
		endif()
	endforeach()
	foreach(k ${__cpack_add_component_ONE} ${__cpack_add_component_MULTI})
		if(DEFINED __csac_${k})
			list(APPEND __csac_add_args ${k} ${__csac_${k}})
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] CPACK_COMPONENT_${compname}_${k} = ${__csac_${k}}")
			endif()
		endif()
	endforeach()
	
	# parent?
	if(__csac_PARENT)
		list(APPEND __csac_add_args GROUP ${__csac_PARENT})
	endif()
	
	# add component
	cpack_add_component(${compname} ${__csac_add_args})
	
	# DEFAULT
	if(__csac_DEFAULT)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_DEFAULT TRUE)
	endif()

	# INSTALL
	if(__csac_INSTALL)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_INSTALL ${__csac_INSTALL})
	endif()
	
	# PACKAGE_SUFFIX
	if(__csac_PACKAGE_SUFFIX)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_PACKAGE_SUFFIX ${__csac_PACKAGE_SUFFIX})
	endif()
	
	# ...
endmacro()

macro(cpack_simple_add_component_group groupname)
message("cpack_simple_add_component_group(${groupname} ${ARGN})")
#cpack_add_component_group(groupname
#                         [DISPLAY_NAME name]
#                         [DESCRIPTION description]
#                         [PARENT_GROUP parent]
#                         [EXPANDED]
#                         [BOLD_TITLE])
	cmake_parse_arguments(__csacg "" "" "" ${ARGN})
endmacro()

set(__cpack_simple_parse_component_context)
macro(cpack_simple_parse_component)
#message("cpack_simple_parse_component(${ARGN})")
	# split component declaration and sub-component
	unset(__csac_component)

	set(__csac_group FALSE)
	set(__csac_decl)
	set(__csac_subdecl)
	
	set(__csac_group 0)
	set(__csac_waitfor_end OFF)
	set(__csac_end_of_args OFF)
	
	foreach(__csac_arg ${ARGN})
		if(NOT __csac_waitfor_end)
			if(__csac_arg STREQUAL BEGIN)
				set(__csac_group 1)
				set(__csac_waitfor_end ON)
			elseif(__csac_arg STREQUAL GROUP)
				set(__csac_group TRUE)
			else()
				if(NOT DEFINED __csac_component)
					set(__csac_component ${__csac_arg})
				else()
					list(APPEND __csac_decl ${__csac_arg})
				endif()
			endif()
		elseif(__csac_end_of_args)
			message(FATAL_ERROR "CPackSimple - unbalance BEGIN-END block: No arguments must follow END")
		else()
			if(__csac_arg STREQUAL BEGIN)
				math(EXPR __csac_group "${__csac_group} + 1")
			elseif(__csac_arg STREQUAL END)
				math(EXPR __csac_group "${__csac_group} - 1")
			endif()
			
			if(__csac_group EQUAL 0)
				set(__csac_end_of_args ON)
			else()
				list(APPEND __csac_subdecl ${__csac_arg})
			endif()
		endif()
	endforeach()

	# === component declaration ===
	cmake_parse_arguments(__csac "GROUP" "" "" ${__csac_decl})
	if(__csac_GROUP)
		cmake_parse_arguments(__csac "GROUP" "" "" ${__csac_decl})
		cpack_simple_add_component_group(${__csac_component} ${__csac_UNPARSED_ARGUMENTS})
	else()
		cpack_simple_add_component(${__csac_component} ${__csac_decl})
	endif()
	
	# === sub-component ===
	if(__csac_subdecl AND NOT "${__csac_subdecl}" STREQUAL "")
		cpack_simple_stack(__cpack_simple_parse_component_context PUSH ${__csac_component})
		
	    cpack_simple_parse_component(${__csac_subdecl} PARENT ${__csac_component})
	    
#		cpack_simple_stack(__cpack_simple_parse_component_context TOP __csac_component)
		cpack_simple_stack(__cpack_simple_parse_component_context POP)
	endif()
	
	# clean variable prefix
	string(LENGTH __cpack_simple_component_varprefix __cpack_simple_component_varlength)
	math(EXPR __cpack_simple_component_varlength "${__cpack_simple_component_varlength} - 1")
	string(SUBSTRING "${__cpack_simple_component_varprefix}" 0 ${__cpack_simple_component_varlength} __cpack_simple_component_varprefix)
endmacro()

