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

set(__cpack_add_component_group_OPT "EXPANDED;BOLD_TITLE")
set(__cpack_add_component_group_ONE "DISPLAY_NAME;DESCRIPTION")
set(__cpack_add_component_group_MULTI "")
macro(cpack_simple_add_component_group groupname)
#cpack_add_component_group(groupname
#                         [DISPLAY_NAME name]
#                         [DESCRIPTION description]
#                         [PARENT_GROUP parent]
#                         [EXPANDED]
#                         [BOLD_TITLE])
	cmake_parse_arguments(__csacg "${__cpack_add_component_group_OPT};DEFAULT" "${__cpack_add_component_group_ONE};PARENT;INSTALL;PACKAGE_SUFFIX" "${__cpack_add_component_group_MULTI}" ${ARGN})
	
	if(__csacg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple - invalid arguments passed to cpack_simple_add_component: ${__csacg_UNPARSED_ARGUMENTS}")
	endif()
	
	# re-generate arguments for cpack_add_component_group
	set(__csacg_add_args)
	foreach(k ${__cpack_add_component_group_OPT})
		if(DEFINED __csacg_${k} AND __csacg_${k})
			list(APPEND __csacg_add_args ${k})
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] CPACK_COMPONENT_${compname}_${k} = TRUE")
			endif()
		endif()
	endforeach()
	foreach(k ${__cpack_add_component_group_ONE} ${__cpack_add_component_group_MULTI})
		if(DEFINED __csacg_${k})
			list(APPEND __csacg_add_args ${k} ${__csacg_${k}})
			if(__cpack_simple_report)
				message(STATUS "[CPackSimple] CPACK_COMPONENT_${compname}_${k} = ${__csacg_${k}}")
			endif()
		endif()
	endforeach()
	
	# parent?
	if(__csacg_PARENT)
		list(APPEND __csacg_add_args PARENT_GROUP ${__csacg_PARENT})
	endif()
	
	# add component
	cpack_add_component_group(${compname} ${__csacg_add_args})
	
	# DEFAULT
	if(__csacg_DEFAULT)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_DEFAULT TRUE)
	endif()

	# INSTALL
	if(__csacg_INSTALL)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_INSTALL ${__csacg_INSTALL})
	endif()
	
	# PACKAGE_SUFFIX
	if(__csacg_PACKAGE_SUFFIX)
		cpack_simple_set(CPACK_SIMPLE_COMPONENT_${compname}_PACKAGE_SUFFIX ${__csacg_PACKAGE_SUFFIX})
	endif()
	
	# ...
endmacro()

set(__cpack_simple_parse_component_context)
macro(cpack_simple_parse_component)
	# === split component declaration and sub-components
	unset(__cspc_component)

	set(__cspc_group FALSE)
	set(__cspc_decl)
	set(__cspc_subdecl)
	set(__cspc_subdecl_n 0)
	
	set(__cspc_group 0)
	set(__cspc_waitfor_end OFF)
	set(__cspc_end_of_args OFF)
	
	foreach(__cspc_arg ${ARGN})
		if(NOT __cspc_waitfor_end)
			if(__cspc_arg STREQUAL BEGIN)
				set(__cspc_group 1)
				set(__cspc_waitfor_end ON)
				math(EXPR __cspc_subdecl_n "${__cspc_subdecl_n} + 1")
				set(__cspc_subdecl${__cspc_subdecl_n})
			elseif(__cspc_arg STREQUAL GROUP)
				set(__cspc_group TRUE)
			else()
				if(NOT DEFINED __cspc_component)
					set(__cspc_component ${__cspc_arg})
				else()
					list(APPEND __cspc_decl ${__cspc_arg})
				endif()
			endif()
		elseif(__cspc_end_of_args)
			if(__cspc_arg STREQUAL BEGIN)
				set(__cspc_group 1)
				set(__cspc_waitfor_end ON)
				set(__cspc_end_of_args FALSE)
				math(EXPR __cspc_subdecl_n "${__cspc_subdecl_n} + 1")
				set(__cspc_subdecl${__cspc_subdecl_n})
			else()
				message(FATAL_ERROR "CPackSimple - unbalance BEGIN-END block: No arguments must follow END")
			endif()
		else()
			if(__cspc_arg STREQUAL BEGIN)
				math(EXPR __cspc_group "${__cspc_group} + 1")
			elseif(__cspc_arg STREQUAL END)
				math(EXPR __cspc_group "${__cspc_group} - 1")
			endif()
			
			if(__cspc_group EQUAL 0)
				set(__cspc_end_of_args ON)
			else()
				list(APPEND __cspc_subdecl${__cspc_subdecl_n} ${__cspc_arg})
			endif()
		endif()
	endforeach()

	# === component declaration ===
	cmake_parse_arguments(__cspc "GROUP" "" "" ${__cspc_decl})
	if(__cspc_GROUP)
		cmake_parse_arguments(__cspc "GROUP" "" "" ${__cspc_decl})
		cpack_simple_add_component_group(${__cspc_component} ${__cspc_UNPARSED_ARGUMENTS})
	else()
		cpack_simple_add_component(${__cspc_component} ${__cspc_decl})
	endif()
	
	# === sub-component(s) ===
	if(__cspc_subdecl_n GREATER 0)
		set(__cspc_${__cspc_component}_i 1)
		set(__cspc_${__cspc_component}_n ${__cspc_subdecl_n})

		while(${__cspc_${__cspc_component}_i} LESS_EQUAL ${__cspc_${__cspc_component}_n})
			cpack_simple_stack(__cpack_simple_parse_component_context PUSH ${__cspc_component})
			
		    cpack_simple_parse_component(${__cspc_subdecl${__cspc_${__cspc_component}_i}} PARENT ${__cspc_component})
		    
			cpack_simple_stack(__cpack_simple_parse_component_context TOP __cspc_component)
			cpack_simple_stack(__cpack_simple_parse_component_context POP)
			
			math(EXPR __cspc_${__cspc_component}_i "${__cspc_${__cspc_component}_i} + 1")
		endwhile()
	endif()
endmacro()

