macro(cpack_simple_configure)
	cmake_parse_arguments(__cpack_simple "" "NAME;CONTACT;VENDOR;SUMMARY;ICON" "VERSION;DESCRIPTION;LICENSE;URL;PACKAGE;COMPONENTS" ${ARGN})
	
	# ===[CPack] NAME, VENDOR, CONTACT, SUMMARY
    if(NOT __cpack_simple_NAME)
        string(TOLOWER ${PROJECT_NAME}  __cpack_simple_NAME)
        message(AUTHOR_WARNING "CPackSimple: NAME is set from PACKAGE_NAME (${PACKAGE_NAME}).")
    endif()

    if(NOT __cpack_simple_VENDOR)
        set(__cpack_simple_VENDOR ${PROJECT_NAME})
        message(AUTHOR_WARNING "CPackSimple: VENDOR is set from PACKAGE_NAME (${PACKAGE_NAME}).")
    endif()

    if(NOT __cpack_simple_CONTACT)
        message(FATAL_ERROR "CPackSimple: CONTACT is required.")
    endif()

    if(NOT __cpack_simple_SUMMARY)
        message(FATAL_ERROR "CPackSimple: SUMMARY is required.")
    endif()
    
    cpack_simple_set(CPACK_PACKAGE_NAME ${__cpack_simple_NAME})
    cpack_simple_set(CPACK_PACKAGE_VENDOR "${__cpack_simple_VENDOR}")
    cpack_simple_set(CPACK_PACKAGE_CONTACT "${__cpack_simple_CONTACT}")
    cpack_simple_set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${__cpack_simple_SUMMARY}")

    # ===[CPack] VERSION
    if(__cpack_simple_VERSION)
	    cpack_simple_configure_version(${__cpack_simple_VERSION})
    else()
	    cpack_simple_configure_version( 
		    MAJOR ${PROJECT_VERSION_MAJOR}
		    MINOR ${PROJECT_VERSION_MINOR}
		    PATCH ${PROJECT_VERSION_PATCH})
    endif()

	# ===[CPack] DESCRIPTION
    if(__cpack_simple_DESCRIPTION)
	    cpack_simple_configure_description(${__cpack_simple_DESCRIPTION})
    endif()

	# ===[CPack] LICENSE
    if(__cpack_simple_LICENSE)
	    cpack_simple_configure_license(${__cpack_simple_LICENSE})
    endif()

	# === [Simple] ICON, URL
	if(__cpack_simple_ICON)
		cpack_simple_configure_icon(${__cpack_simple_ICON})
	endif()
	
	if(__cpack_simple_URL)
		cpack_simple_configure_url(${__cpack_simple_URL})
	endif()
	
	# === [Simple] PACKAGE
	if(__cpack_simple_PACKAGE)
		cpack_simple_configure_package(${__cpack_simple_PACKAGE})
	endif(__cpack_simple_PACKAGE)
	
	# === [Simple] COMPONENTS
	if(__cpack_simple_COMPONENTS)
		cpack_simple_configure_components(${__cpack_simple_COMPONENTS})
	endif(__cpack_simple_COMPONENTS)
endmacro()


macro(cpack_simple_configure_version)
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
    
    cpack_simple_set(CPACK_PACKAGE_VERSION ${__cpack_simple_version})
endmacro()

macro(cpack_simple_configure_description)
    cmake_parse_arguments(__cpack_simple_description "" "FILE" "" ${ARGN})
    if(__cpack_simple_description_FILE)
        cpack_simple_set(PACKAGE_DESCRIPTION_FILE "${__cpack_simple_description_FILE}")
        # FIXME read file into CPACK_PACKAGE_DESCRIPTION?
    endif()

	if(__cpack_simple_description_UNPARSED_ARGUMENTS)    
	    cpack_simple_set(CPACK_PACKAGE_DESCRIPTION "${__cpack_simple_description_UNPARSED_ARGUMENTS}")
    endif()
endmacro()

macro(cpack_simple_configure_license)
    cmake_parse_arguments(__cpack_simple_license "" "FILE" "" ${ARGN})
    
    if(__cpack_simple_license_UNPARSED_ARGUMENTS)
        cpack_simple_set(CPACK_PACKAGE_LICENSE "${__cpack_simple_license_UNPARSED_ARGUMENTS}")
    endif()
    
    if(__cpack_simple_license_FILE)
        cpack_simple_set(CPACK_RESOURCE_FILE_LICENSE "${__cpack_simple_license_FILE}")        
    endif()
endmacro()

macro(cpack_simple_configure_icon)
    cmake_parse_arguments(__cpack_simple_icon "" "INSTALL;UNINSTALL" "" ${ARGN})
    
    if(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(CPACK_SIMPLE_ICON "${__cpack_simple_icon_UNPARSED_ARGUMENTS}")
    endif()
    
    if(__cpack_simple_icon_INSTALL)
        cpack_simple_set(CPACK_SIMPLE_ICON_INSTALL "${__cpack_simple_icon_INSTALL}")
    elseif(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(CPACK_SIMPLE_ICON_INSTALL ${CPACK_SIMPLE_ICON})
    endif()
    
    if(__cpack_simple_icon_UNINSTALL)
        cpack_simple_set(CPACK_SIMPLE_ICON_UNINSTALL "${__cpack_simple_icon_UNINSTALL}")
    elseif(__cpack_simple_icon_INSTALL)
        cpack_simple_set(CPACK_SIMPLE_ICON_UNINSTALL ${__cpack_simple_icon_INSTALL})
    elseif(__cpack_simple_icon_UNPARSED_ARGUMENTS)
        cpack_simple_set(CPACK_SIMPLE_ICON_UNINSTALL ${CPACK_SIMPLE_ICON})
    endif()
endmacro()

macro(cpack_simple_configure_url)
	cmake_parse_arguments(__cpack_simple_url "" "HOMEPAGE;ABOUT;HELP" "" ${ARGN})

	if(__cpack_simple_url_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "CPackSimple: invalid URL syntax.")
	endif()
	
	if(__cpack_simple_url_HOMEPAGE)
		cpack_simple_set(CPACK_SIMPLE_URL_HOMEPAGE ${__cpack_simple_url_HOMEPAGE})
	endif()
	
	if(__cpack_simple_url_ABOUT)
		cpack_simple_set(CPACK_SIMPLE_URL_ABOUT ${__cpack_simple_url_ABOUT})
	endif()
	
	if(__cpack_simple_url_HELP)
		cpack_simple_set(CPACK_SIMPLE_URL_HELP ${__cpack_simple_url_HELP})
	endif()
endmacro()


