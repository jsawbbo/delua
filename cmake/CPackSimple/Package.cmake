include(CPackSimple/Package/DEB)
include(CPackSimple/Package/DMG)
include(CPackSimple/Package/NSIS)
include(CPackSimple/Package/RPM)

macro(cpack_simple_configure_package)
	cmake_parse_arguments(__cpack_simple_package "" "GROUP" "" ${ARGN})

	if(__cpack_simple_package_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple: invalid PACKAGE syntax.")
	endif()
	
	if(__cpack_simple_package_GROUP)
		cpack_simple_set(CPACK_SIMPLE_PACKAGE_GROUP ${__cpack_simple_package_GROUP})
	endif()
endmacro()

macro(cpack_simple_package pkgtype)
	if(${pkgtype} STREQUAL DEB)
		cpack_simple_package_deb(${ARGN})
	elseif(pkgtype STREQUAL DMG)
		cpack_simple_package_dmg(${ARGN})
	elseif(pkgtype STREQUAL NSIS)
		cpack_simple_package_nsis(${ARGN})
	elseif(pkgtype STREQUAL RPM)
		cpack_simple_package_rpm(${ARGN})
	else()
		message(FATAL_ERROR "CPackSimple - unknown package type: '${pkgtype}' (allowed: DEB, DMG, NSIS, RPM).")
	endif()
endmacro()



