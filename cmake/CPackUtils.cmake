#.rst:
# Package and distribution utilities
# ----------------------------------
#
# Tools and utitilities for setting up CPack.
#
# Inspired by and some code copied from
#     https://github.com/neurosuite/libneurosuite/blob/master/cmake/modules/PackNeurosuite.cmake,
#     Copyright 2015 by Florian Franzen
# 
# See 
#     https://gitlab.kitware.com/cmake/community/wikis/doc/cpack/Packaging-With-CPack
# for more information.

include(InstallRequiredSystemLibraries)
include(CPackComponent)

set(__cpackutils_debug_output OFF)
function(__cpackutils_debug)
    if(__cpackutils_debug_output)
        message(STATUS ${ARGN})
    endif()
endfunction()

#[=======================================================================[.rst:
CPackSetup

Setup and initialize basic/common CPack variables.

.. command: CPackSetup

    ::
        CPackSetup(
            [NAME <name>]
            [VERSION <version>
                [MAJOR <major-version>
                MINOR <minor-version>
                PATCH <patch-version>]]
            [VENDOR <vendor>]
            CONTACT <contact>
            SUMMARY <summary>
            [DESCRIPTION [<description>]
                [FILE <description-file>]]
            [LICENSE [<license>]
                [FILE <license-file>]]
        )
 
    ``<name>``: Package name, default: PROJECT_NAME
    
    ``<version>``: Package version (x.y or x.y.z format), default: PROJECT_VERSION
                   Alternatively, use ``<major-version>``, ``<minor-version>``, and, ``<patch-version>``. 
    
    ``<vendor>``: Package vendor, default: PROJECT_NAME
    
    ``<contact>``: Name and email address of maintainer, e.g. "First Last <First.Last@domain.com>"
      
    ``<summary>``: Package summary (short description).
    
    ``<description>``: Full package description (usually populated from DESCRIPTION_FILE).

    ``<description-file>``: Path to full package description file, e.g path/to/README.txt.

    ``<license>``: Package license.
    
    ``<license-file>``: Path to full license file, e.g. path/to/LICENSE.
    
#]=======================================================================]
function(CPackSetup)
    __cpackutils_debug("CPackSetup()")
    cmake_parse_arguments(_ "" "NAME;VENDOR;CONTACT;SUMMARY" "VERSION;DESCRIPTION;LICENSE" ${ARGN})
    
    # === defaults
    set(CPACK_GENERATOR "ZIP" PARENT_SCOPE)
    set(CPACK_SYSTEM_NAME
        "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}"
        PARENT_SCOPE)
    set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)

    # === NAME, VENDOR, CONTACT and SUMMARY
    if(NOT __NAME)
        string(TOLOWER ${PROJECT_NAME}  __NAME)
    endif()

    if(NOT __VENDOR)
        set(__VENDOR ${PROJECT_NAME})
    endif()

    if(NOT __CONTACT)
        message(FATAL_ERROR "Option CONTACT is required.")
    endif()

    if(NOT __SUMMARY)
        message(FATAL_ERROR "Option SUMMARY is required.")
    endif()

    set(CPACK_PACKAGE_NAME ${__NAME} PARENT_SCOPE)
    __cpackutils_debug("    CPACK_PACKAGE_NAME=${__NAME}")
    
    set(CPACK_PACKAGE_VENDOR "${__VENDOR}" PARENT_SCOPE)
    __cpackutils_debug("    CPACK_PACKAGE_VENDOR=${__VENDOR}")
    
    set(CPACK_PACKAGE_CONTACT "${__CONTACT}" PARENT_SCOPE)
    __cpackutils_debug("    CPACK_PACKAGE_CONTACT=${__CONTACT}")
    
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${__SUMMARY}" PARENT_SCOPE)
    __cpackutils_debug("    CPACK_PACKAGE_DESCRIPTION_SUMMARY=${__SUMMARY}")
        
    # === VERSION        
    if(__VERSION)
        cmake_parse_arguments(__VERSION "" "MAJOR;MINOR;PATCH" "" ${__VERSION})
        if(__VERSION_MAJOR)
            if(__VERSION_UNPARSED_ARGUMENTS OR NOT __VERSION_MINOR)
                message(FATAL_ERROR "Invalid arguments passed to option `VERSION`.")
            endif()
        else()
            if(NOT __VERSION_UNPARSED_ARGUMENTS)
                message(FATAL_ERROR "Invalid arguments passed to option `VERSION`.")
            endif()
            
            string(REGEX REPLACE "^([0-9]+)\\.[0-9]+.*" "\\1" __VERSION_MAJOR ${__VERSION})
            if(__VERSION_MAJOR STREQUAL __VERSION)
                message(FATAL_ERROR "Invalid version string format (expected x.y or x.y.z).")
            endif()
            string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" __VERSION_MINOR ${__VERSION})
            string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" __VERSION_PATCH ${__VERSION})
            if(__VERSION_PATCH STREQUAL __VERSION)
                unset(__VERSION_PATCH)
            endif()
        endif()
    else()
        set(__VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
        set(__VERSION_MINOR ${PROJECT_VERSION_MINOR})
        set(__VERSION_PATCH ${PROJECT_VERSION_PATCH})
    endif()

    if(__VERSION_PATCH)
        set(__VERSION ${__VERSION_MAJOR}.${__VERSION_MINOR}.${__VERSION_PATCH})
    else()
        set(__VERSION ${__VERSION_MAJOR}.${__VERSION_MINOR})
    endif()
    
    set(CPACK_PACKAGE_VERSION ${__VERSION} PARENT_SCOPE)
    __cpackutils_debug("    CPACK_PACKAGE_VERSION=${__VERSION}")
    
    # === DESCRIPTION    
    if(__DESCRIPTION)
        cmake_parse_arguments(__DESCRIPTION "" "FILE" "" ${__DESCRIPTION})
        if(__DESCRIPTION_FILE)
            set(CPACK_PACKAGE_DESCRIPTION_FILE "${__DESCRIPTION_FILE}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_PACKAGE_DESCRIPTION_FILE=${__DESCRIPTION_FILE}")
        else()
            set(CPACK_PACKAGE_DESCRIPTION "${__DESCRIPTION}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_PACKAGE_DESCRIPTION=\"${__DESCRIPTION}\"")
        endif()
    endif()

    # === LICENSE
    if(__LICENSE)
        cmake_parse_arguments(__LICENSE "" "FILE" "" ${__LICENSE})
        if(__LICENSE_UNPARSED_ARGUMENTS)
            set(CPACK_PACKAGE_LICENSE "${__LICENSE_UNPARSED_ARGUMENTS}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_PACKAGE_LICENSE=${__LICENSE_UNPARSED_ARGUMENTS}")
        endif()
        if(__LICENSE_FILE)
            set(CPACK_RESOURCE_FILE_LICENSE "${__LICENSE_FILE}" PARENT_SCOPE)        
            __cpackutils_debug("    CPACK_RESOURCE_FILE_LICENSE=${__LICENSE_FILE}")
        endif()
    endif()
endfunction()

#[=======================================================================[.rst:
CPackCommon

Common package settings.

.. command: CPackCommon

    ::
        CPackCommon(
            [HOMEPAGE <homepage>]
            [ABOUT_URL <about-url>]
            [HELP_URL <help-url>]
            [ICON <icon-file>]
            [SECTION|GROUP <package-group-or-section>]
        )

#]=======================================================================]
function(CPackCommon)
    __cpackutils_debug("CPackCommon()")
        
    set(options "HOMEPAGE;ABOUT_URL;HELP_URL;ICON")
    cmake_parse_arguments(_ "" "${options};SECTION;GROUP" "" ${ARGN})
    
    if(__UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Invalid arguments: ${__UNPARSED_ARGUMENTS}")
    endif()
    if(__SECTION AND __GROUP)
        message(FATAL_ERROR "Invalid arguments: SECTION and GROUP provided.")
    endif()
    
    foreach(opt ${options})
        if(DEFINED __${opt})
            set(CPACK_PACKAGE_${opt} ${__${opt}} PARENT_SCOPE)
            __cpackutils_debug("    CPACK_PACKAGE_${opt}=${__${opt}}")
        endif()
    endforeach()

    if(__SECTION)
        set(__GROUP ${__SECTION})
    endif()
    if(__GROUP) 
        set(CPACK_PACKAGE_GROUP ${__GROUP} PARENT_SCOPE)
        __cpackutils_debug("    CPACK_PACKAGE_GROUP=${__GROUP}")
    endif()
endfunction()
        
#[=======================================================================[.rst:
CPackComponents

Declare and setup components.

.. command: CPackComponents

    ::
        CPackComponents(ALL <component-list> [IN_ONE][IGNORE]])
        CPackComponent(<component>
                [...]
            ]
        )

#]=======================================================================]
function(CPackComponents compName)
    __cpackutils_debug("CPackComponents(${compName})")
    
    # === ALL
    if(compName STREQUAL ALL)
        cmake_parse_arguments(_ "IN_ONE;IGNORE" "" "" ${ARGN})
        if(CPACK_COMPONENTS_ALL)
            message(FATAL_ERROR "CPack components cannot be overridden.")
        endif()
        
        set(CPACK_COMPONENTS_ALL ${__UNPARSED_ARGUMENTS})
        set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} PARENT_SCOPE)
        __cpackutils_debug("    CPACK_COMPONENTS_ALL=${CPACK_COMPONENTS_ALL}")
        
        if (__IN_ONE)
            set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE PARENT_SCOPE)
            __cpackutils_debug("        CPACK_COMPONENTS_GROUPING=ALL_COMPONENTS_IN_ONE")
        elseif(__IGNORE)
            set(CPACK_COMPONENTS_GROUPING IGNORE PARENT_SCOPE)
            __cpackutils_debug("        CPACK_COMPONENTS_GROUPING=IGNORE")
        endif()
    # === COMPONENT
    else()
        if(NOT DEFINED CPACK_COMPONENTS_ALL)
            message(FATAL_ERROR "No components defined.")
        endif()
        
        __cpackutils_debug("    adding component ${compName}")
        cmake_parse_arguments(_ "DEFAULT" "PACKAGE_SUFFIX" "DEPENDS" ${ARGN})
        
        # DEFAULT
        if(__DEFAULT)
            set(CPACK_COMPONENT_${compName}_PACKAGE_SUFFIX "" PARENT_SCOPE)
            
            if(__PACKAGE_SUFFIX)
                message(FATAL_ERROR "Invalid arguments passed: DEFAULT and PACKAGE_SUFFIX are mutually exclusive")
            endif()
        endif()
        
        # PACKAGE_SUFFIX
        if(__PACKAGE_SUFFIX)
            set(CPACK_COMPONENT_${compName}_PACKAGE_SUFFIX "-${__PACKAGE_SUFFIX}" PARENT_SCOPE)
            __cpackutils_debug("        CPACK_COMPONENT_${compName}_PACKAGE_SUFFIX=-${__PACKAGE_SUFFIX}")
        endif()

        # DEPENDS
        if(__DEPENDS)
            set(CPACK_COMPONENT_${compName}_DEPENDS "${__DEPENDS}" PARENT_SCOPE)
            __cpackutils_debug("        CPACK_COMPONENT_${compName}_DEPENDS=${__DEPENDS}")
        endif()
            
        # FIXME ...
        
        # other options
        cpack_add_component(${compName} ${__UNPARSED_ARGUMENTS})
    endif()
endfunction()
        
#[=======================================================================[.rst:
CPackXYZ

FIXME

.. command: CPackXYZ

    ::
        CPackXYZ(
        )

#]=======================================================================]
function(CPackXYZ)
endfunction()

############################
# Windows specific helpers #
############################

#[=======================================================================[.rst:
CPackDefineNSIS

Define NSIS pacakge.

.. command: CPackDefineNSIS

    ::
        CPackDefineNSIS(
        )

#]=======================================================================]
function(CPackDefineNSIS)
    if(WIN32)
        set(CPACK_GENERATOR "NSIS" PARENT_SCOPE)

#        # Set name in installer and Add/Remove Program
#        set(CPACK_NSIS_PACKAGE_NAME "${_STYLED_NAME}" PARENT_SCOPE)
#        set(CPACK_NSIS_DISPLAY_NAME "${_STYLED_NAME}" PARENT_SCOPE)
#
#        # Set install and registry path
#        set(CPACK_PACKAGE_INSTALL_DIRECTORY "${_STYLED_NAME}" PARENT_SCOPE)
#
#        set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${_TARGET} PARENT_SCOPE)
#
#        # Add link to executable to Start menu
#        set(CPACK_PACKAGE_EXECUTABLES
#            "${_TARGET}" "${_STYLED_NAME}"
#            PARENT_SCOPE)
#
#        # Add license file and default contact info
#        if(_LICENSE_FILE)
#            set(CPACK_RESOURCE_FILE_LICENSE "${_LICENSE_FILE}" PARENT_SCOPE)
#        endif()
#        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT} PARENT_SCOPE)
#
#        # Ask if previous version should be uninstalled
#        set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON PARENT_SCOPE)
#
#        # Add website links to Start menu and installer
#        set(CPACK_NSIS_MENU_LINKS
#            "http:////neurosuite.github.io" "Homepage of ${_STYLED_NAME}" PARENT_SCOPE)
#        set(CPACK_NSIS_URL_INFO_ABOUT
#            "https:////neurosuite.github.io"
#            PARENT_SCOPE)
#        set(CPACK_NSIS_HELP_LINK
#            "https:////neurosuite.github.io//information.html"
#            PARENT_SCOPE)
#
#        # Fix package name and install root depending on architecture
#        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
#            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64"  PARENT_SCOPE)
#            set(CPACK_SYSTEM_NAME "win64" PARENT_SCOPE)
#        else()
#            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES32"  PARENT_SCOPE)
#            set(CPACK_SYSTEM_NAME "win32" PARENT_SCOPE)
#        endif()
    endif()
endfunction()

##########################
# Apple specific helpers #
##########################
#[=======================================================================[.rst:
CPackDefineDMG

Create DMG (Apple/OSx) package.

.. command: CPackDefineDMG

    ::
        CPackDefineDMG(
        )

#]=======================================================================]
function(CPackDefineDMG)
    if(APPLE)
        set(CPACK_GENERATOR "DragNDrop" PARENT_SCOPE)
        set(CPACK_DMG_FORMAT "UDBZ" PARENT_SCOPE)
        set(CMAKE_INSTALL_PREFIX "/Applications" PARENT_SCOPE)
        set(CPACK_SYSTEM_NAME "osx-${CMAKE_SYSTEM_PROCESSOR}" PARENT_SCOPE)
    endif()
endfunction()

#########################
# UNIX specific helpers #
#########################
macro(_CPackEval _result _value)
    set(${_result} ${_value} ${ARGN})
endmacro()

macro(_CPackReadShellVars _FILE_NAME _VAR_PREFIX)
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

#[=======================================================================[.rst:
CPackUnixSysInfo

Get UNIX system information.

.. command: CPackUnixSysInfo

    ::
        CPackUnixSysInfo(<dist-variable> <version-variable> <codename-variable> <architecture-variable>)

#]=======================================================================]
function(CPackUnixSysInfo _DIST_VAR _VERSION_VAR _CODENAME_VAR _ARCH_VAR)
    if(UNIX AND NOT APPLE)
        # Read distribution, release, and, codename from /etc/lsb-release and /etc/os-release - if present.
        if(EXISTS /etc/lsb-release)
            _CPackReadShellVars(/etc/lsb-release _)
            set(${_DIST_VAR} "${_DISTRIB_ID}" PARENT_SCOPE)
            set(${_VERSION_VAR} "${_DISTRIB_RELEASE}" PARENT_SCOPE)
            set(${_CODENAME_VAR} "${_DISTRIB_CODENAME}" PARENT_SCOPE)
        else()
            message(WARNING "LSB-Release file not present - cannot detect distribution type.")
        endif()

        if(EXISTS /etc/os-release)
            # os-release is available on systemd based systems
            _CPackReadShellVars(/etc/os-release _)

            if (_ID_LIKE MATCHES "ubuntu")
                set(${_DIST_VAR} "Ubuntu" PARENT_SCOPE)
            endif()
        endif()

        # Check if dpkg command is there first...
        find_program(DPKG_CMD dpkg)
        if(DPKG_CMD)
            # ... then use it to determine architecture string
            execute_process(COMMAND ${DPKG_CMD} --print-architecture
                OUTPUT_VARIABLE ARCHITECTURE
                OUTPUT_STRIP_TRAILING_WHITESPACE)
            set(${_ARCH_VAR} ${ARCHITECTURE} PARENT_SCOPE)
        else()
            # ... else use uname -p (or whatever they do on Windows or OS X)
            set(${_ARCH_VAR} ${CMAKE_SYSTEM_PROCESSOR} PARENT_SCOPE)
        endif()
    endif()
endfunction()

#[=======================================================================[.rst:
CPackDefineDEB

Create a Debian-style package.

.. command: CPackDefineDEB

    ::
        CPackDefineDEB(<distribution>
            [MAINTAINER <contact-email>]
            [TEMPLATE <output-template>]
            [SCRIPT_DIR <installation-script-directory>]
            [DEPENDS <dependencies>]
            [SUGGESTS <suggested>]
            [RECOMMENDS <recommends>]
            [BREAKS <breaks>]
            [CONFLICTS <conflicts>]
            [SECTION|GROUP <section>]
        )


    ``distribution``: The distribution this definition is specified for (e.g. "Ubuntu").

    ``contact-email``: Package maintainer contact email (if different from contact provided to CPackSetup).

    ``output-template``: Template for package file name (default: "\${NAME}_\${VERSION}-\${CODENAME}_\${ARCHITECTURE}")

    ``installation-script-directory``: Debian-style installation script directory.

    ``codename``: Override of the auto-detected distribution 'codename'.

    ``dependencies``: Package dependencies.
    
    ``suggested``: List of suggested packages.

    ``recommends``: List of recommended packages.
    
    ``breaks``: List of packages that will break by installing this package.
    
    ``conflicts``: List of conflicting packages.

    ``section``: Package section or group.

#]=======================================================================]
function(CPackDefineDEB _DIST_NAME)
    CPackUnixSysInfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
        __cpackutils_debug("CPackDefineDEB(${_DIST_NAME})")
        set(CPACK_GENERATOR "DEB" PARENT_SCOPE)
        set(CPACK_DEB_COMPONENT_INSTALL TRUE PARENT_SCOPE)

        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CPACK_PACKAGE_HOMEPAGE}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_HOMEPAGE=${CPACK_PACKAGE_HOMEPAGE}")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_ARCHITECTURE=${ARCHITECTURE}")
        
        cmake_parse_arguments(_ "" "MAINTAINER;TEMPLATE;SCRIPT_DIR;SECTION;GROUP" "DEPENDS;SUGGESTS;RECOMMENDS;BREAKS;CONFLICTS" ${ARGN})
    
        # === MAINTAINER
        if(__MAINTAINER)
            set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${__MAINTAINER}")
        else()
            set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}")
        endif()
        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_MAINTAINER=${CPACK_DEBIAN_PACKAGE_MAINTAINER}")
        set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_DEBIAN_PACKAGE_MAINTAINER}" PARENT_SCOPE)

        # === SECTION/GROUP
        if(__GROUP)
            if(__SECTION)
                message(FATAL_ERROR "Invalid parameter: SECTION or GROUP")
            endif()
            
            set(__SECTION "${__GROUP}")
        else()
            set(__SECTION "${CPACK_PACKAGE_GROUP}")
        endif()
        
        set(CPACK_DEBIAN_PACKAGE_SECTION "${__SECTION}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_SECTION=${__SECTION}")

        # BUILD_DEPENDS;DEPENDS;SUGGESTS;CONFICTS;BREAKS
        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_DEPENDS "${__DEPENDS}")
        set(CPACK_DEBINA_PACKAGE_DEPENDS "${CPACK_DEBINA_PACKAGE_DEPENDS}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_DEPENDS=${CPACK_DEBINA_PACKAGE_DEPENDS}")

        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_RECOMMENDS "${__RECOMMENDS}")
        set(CPACK_DEBINA_PACKAGE_RECOMMENDS "${CPACK_DEBINA_PACKAGE_RECOMMENDS}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_RECOMMENDS=${CPACK_DEBINA_PACKAGE_RECOMMENDS}")

        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_SUGGESTS "${__SUGGESTS}")
        set(CPACK_DEBINA_PACKAGE_SUGGESTS "${CPACK_DEBINA_PACKAGE_SUGGESTS}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_SUGGESTS=${CPACK_DEBINA_PACKAGE_SUGGESTS}")

        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_BREAKS "${__BREAKS}")
        set(CPACK_DEBINA_PACKAGE_BREAKS "${CPACK_DEBINA_PACKAGE_BREAKS}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_BREAKS=${CPACK_DEBINA_PACKAGE_BREAKS}")

        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_CONFLICTS "${__CONFLICTS}")
        set(CPACK_DEBINA_PACKAGE_CONFLICTS "${CPACK_DEBINA_PACKAGE_CONFLICTS}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_CONFLICTS=${CPACK_DEBINA_PACKAGE_CONFLICTS}")


        # === SCRIPT_DIR
        if(__SCRIPT_DIR)
            foreach(SCRIPT shlibs postinst prerm postrm)
                if(EXISTS "${__SCRIPT_DIR}/${SCRIPT}")
                    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
                    "${__SCRIPT_DIR}/${SCRIPT}")
                endif()
            endforeach()
            set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA} PARENT_SCOPE)
            __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA=${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}")
        endif()

        # === FILE_NAME (TEMPLATE)
        set(NAME ${CPACK_PACKAGE_NAME})
        set(VERSION ${CPACK_PACKAGE_VERSION})
        if(NOT DEFINED __TEMPLATE)
            set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
        else()
            _CPackEval(CPACK_DEBIAN_FILE_NAME "${__TEMPLATE}.deb")
        endif()
        set(CPACK_DEBIAN_FILE_NAME "${CPACK_DEBIAN_FILE_NAME}" PARENT_SCOPE)
        __cpackutils_debug("    CPACK_DEBIAN_FILE_NAME=${CPACK_DEBIAN_FILE_NAME}")
        
        # === COMPONENTS
        set(CPACK_DEB_PACKAGE_COMPONENT TRUE PARENT_SCOPE)
        foreach(component ${CPACK_COMPONENTS_ALL})
            string(TOUPPER "${component}" COMPONENT)
            
            if(DEFINED CPACK_COMPONENT_${component}_PACKAGE_SUFFIX)
                set(SUFFIX "${CPACK_COMPONENT_${component}_PACKAGE_SUFFIX}")
            else()
                set(SUFFIX "-${component}")
            endif()
            
            # PACKAGE_NAME
            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME "${NAME}${SUFFIX}")
            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME=${NAME}")
            
            # FILE_NAME
            if(NOT DEFINED __TEMPLATE)
                set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "DEB-DEFAULT")
            else()
                _CPackEval(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "${__TEMPLATE}${SUFFIX}.deb")
            endif()
            set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "${CPACK_DEBIAN_${COMPONENT}_FILE_NAME}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_FILE_NAME=${CPACK_DEBIAN_${COMPONENT}_FILE_NAME}")
        endforeach()
        
        # PACKAGE_DEPENDS
        foreach(component ${CPACK_COMPONENTS_ALL})
            string(TOUPPER "${component}" COMPONENT)
        
            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${__DEPENDS})
            foreach(dep ${CPACK_COMPONENT_${component}_DEPENDS})
                string(TOUPPER "${dep}" DEP)
                if(DEFINED CPACK_DEBIAN_${DEP}_PACKAGE_NAME)
                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${CPACK_DEBIAN_${DEP}_PACKAGE_NAME})
                else()
                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${dep})
                endif()
            endforeach()
            string(REPLACE ";" ", " CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}" PARENT_SCOPE)
            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS=${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
        endforeach()
    endif()
endfunction(CPackDefineDEB)

#[=======================================================================[.rst:
CPackDefineRPM

Defined RPM (Redhat) package.

.. command: CPackDefineRPM

    ::
        CPackDefineRPM(
        )

#]=======================================================================]
function(CPackDefineRPM _DIST_NAME)
    CPackUnixSysInfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
#        set(CPACK_GENERATOR "RPM" PARENT_SCOPE)
#
#        # Set defaults
#        set(CPACK_RPM_PACKAGE_GROUP "Science" PARENT_SCOPE)
#        set(CPACK_RPM_PACKAGE_LICENSE "GPLv2" PARENT_SCOPE)
#        set(CPACK_RPM_PACKAGE_URL "http://neurosuite.github.io" PARENT_SCOPE)
#
#        # Set architecture
#        set(CPACK_RPM_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)
#
#        # Set dependencies
#        set(CPACK_RPM_PACKAGE_REQUIRES ${_REQUIRES} PARENT_SCOPE)
#
#        # Determine suggested packages
#        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
#        string(REPLACE ";" ", "
#               CPACK_RPM_PACKAGE_SUGGESTS
#               "${GEN_SUGGESTED_PACKAGES}")
#        set(CPACK_RPM_PACKAGE_SUGGESTS
#            "${CPACK_RPM_PACKAGE_SUGGESTS}"
#            PARENT_SCOPE)
#
#        # Add script if path supplied
#        if(_SCRIPT_DIR)
#            if(EXIST "${_SCRIPT_DIR}/postinst")
#                set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE
#                    "${_SCRIPT_DIR}/postinst"
#                    PARENT_SCOPE)
#            endif()
#            if(EXIST "${_SCRIPT_DIR}/postrm")
#                set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE
#                    "${_SCRIPT_DIR}/postrm"
#                    PARENT_SCOPE)
#            endif()
#        endif()
#
#        # Determine package name
#        set(NAME ${CPACK_PACKAGE_NAME})
#        set(VERSION ${CPACK_PACKAGE_VERSION})
#        gen_eval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
    endif()
endfunction(CPackDefineRPM)

