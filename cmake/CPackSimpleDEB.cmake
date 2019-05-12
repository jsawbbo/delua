include(CPackSimpleUnix)

#
##[=======================================================================[.rst:
#CPackDefineDEB
#
#Create a Debian-style package.
#
#.. command: CPackDefineDEB
#
#    ::
#        CPackDefineDEB(<distribution>
#            [MAINTAINER <contact-email>]
#            [TEMPLATE <output-template>]
#            [SCRIPT_DIR <installation-script-directory>]
#            [DEPENDS <dependencies>]
#            [SUGGESTS <suggested>]
#            [RECOMMENDS <recommends>]
#            [BREAKS <breaks>]
#            [CONFLICTS <conflicts>]
#            [SECTION|GROUP <section>]
#        )
#
#
#    ``distribution``: The distribution this definition is specified for (e.g. "Ubuntu").
#
#    ``contact-email``: Package maintainer contact email (if different from contact provided to CPackSetup).
#
#    ``output-template``: Template for package file name (default: "\${NAME}_\${VERSION}-\${CODENAME}_\${ARCHITECTURE}")
#
#    ``installation-script-directory``: Debian-style installation script directory.
#
#    ``codename``: Override of the auto-detected distribution 'codename'.
#
#    ``dependencies``: Package dependencies.
#    
#    ``suggested``: List of suggested packages.
#
#    ``recommends``: List of recommended packages.
#    
#    ``breaks``: List of packages that will break by installing this package.
#    
#    ``conflicts``: List of conflicting packages.
#
#    ``section``: Package section or group.
#
##]=======================================================================]
function(CPackDefineDEB _DIST_NAME)
	if(UNIX AND NOT APPLE)
		cpack_simple_unix_sysinfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)
	endif()
#    cpack_simple_unix_sysinfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)
#
#    if(DISTRIBUTION MATCHES ${_DIST_NAME})
#        __cpackutils_debug("CPackDefineDEB(${_DIST_NAME})")
#        set(CPACK_GENERATOR "DEB" PARENT_SCOPE)
#        set(CPACK_DEB_COMPONENT_INSTALL TRUE PARENT_SCOPE)
#
#        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CPACK_PACKAGE_HOMEPAGE}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_HOMEPAGE=${CPACK_PACKAGE_HOMEPAGE}")
#        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_ARCHITECTURE=${ARCHITECTURE}")
#        
#        cmake_parse_arguments(_ "" "MAINTAINER;TEMPLATE;SCRIPT_DIR;SECTION;GROUP" "DEPENDS;SUGGESTS;RECOMMENDS;BREAKS;CONFLICTS" ${ARGN})
#    
#        # === MAINTAINER
#        if(__MAINTAINER)
#            set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${__MAINTAINER}")
#        else()
#            set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}")
#        endif()
#        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_MAINTAINER=${CPACK_DEBIAN_PACKAGE_MAINTAINER}")
#        set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_DEBIAN_PACKAGE_MAINTAINER}" PARENT_SCOPE)
#
#        # === SECTION/GROUP
#        if(__GROUP)
#            if(__SECTION)
#                message(FATAL_ERROR "Invalid parameter: SECTION or GROUP")
#            endif()
#            
#            set(__SECTION "${__GROUP}")
#        else()
#            set(__SECTION "${CPACK_PACKAGE_GROUP}")
#        endif()
#        
#        set(CPACK_DEBIAN_PACKAGE_SECTION "${__SECTION}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_SECTION=${__SECTION}")
#
#        # BUILD_DEPENDS;DEPENDS;SUGGESTS;CONFICTS;BREAKS
#        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_DEPENDS "${__DEPENDS}")
#        set(CPACK_DEBINA_PACKAGE_DEPENDS "${CPACK_DEBINA_PACKAGE_DEPENDS}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_DEPENDS=${CPACK_DEBINA_PACKAGE_DEPENDS}")
#
#        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_RECOMMENDS "${__RECOMMENDS}")
#        set(CPACK_DEBINA_PACKAGE_RECOMMENDS "${CPACK_DEBINA_PACKAGE_RECOMMENDS}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_RECOMMENDS=${CPACK_DEBINA_PACKAGE_RECOMMENDS}")
#
#        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_SUGGESTS "${__SUGGESTS}")
#        set(CPACK_DEBINA_PACKAGE_SUGGESTS "${CPACK_DEBINA_PACKAGE_SUGGESTS}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_SUGGESTS=${CPACK_DEBINA_PACKAGE_SUGGESTS}")
#
#        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_BREAKS "${__BREAKS}")
#        set(CPACK_DEBINA_PACKAGE_BREAKS "${CPACK_DEBINA_PACKAGE_BREAKS}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_BREAKS=${CPACK_DEBINA_PACKAGE_BREAKS}")
#
#        string(REPLACE ";" ", " CPACK_DEBINA_PACKAGE_CONFLICTS "${__CONFLICTS}")
#        set(CPACK_DEBINA_PACKAGE_CONFLICTS "${CPACK_DEBINA_PACKAGE_CONFLICTS}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBINA_PACKAGE_CONFLICTS=${CPACK_DEBINA_PACKAGE_CONFLICTS}")
#
#
#        # === SCRIPT_DIR
#        if(__SCRIPT_DIR)
#            foreach(SCRIPT shlibs postinst prerm postrm)
#                if(EXISTS "${__SCRIPT_DIR}/${SCRIPT}")
#                    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
#                    "${__SCRIPT_DIR}/${SCRIPT}")
#                endif()
#            endforeach()
#            set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA} PARENT_SCOPE)
#            __cpackutils_debug("    CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA=${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}")
#        endif()
#
#        # === FILE_NAME (TEMPLATE)
#        set(NAME ${CPACK_PACKAGE_NAME})
#        set(VERSION ${CPACK_PACKAGE_VERSION})
#        if(NOT DEFINED __TEMPLATE)
#            set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
#        else()
#            cpack_simple_eval(CPACK_DEBIAN_FILE_NAME "${__TEMPLATE}.deb")
#        endif()
#        set(CPACK_DEBIAN_FILE_NAME "${CPACK_DEBIAN_FILE_NAME}" PARENT_SCOPE)
#        __cpackutils_debug("    CPACK_DEBIAN_FILE_NAME=${CPACK_DEBIAN_FILE_NAME}")
#        
#        # === COMPONENTS
#        set(CPACK_DEB_PACKAGE_COMPONENT TRUE PARENT_SCOPE)
#        foreach(component ${CPACK_COMPONENTS_ALL})
#            string(TOUPPER "${component}" COMPONENT)
#            
#            if(DEFINED CPACK_COMPONENT_${component}_PACKAGE_SUFFIX)
#                set(SUFFIX "${CPACK_COMPONENT_${component}_PACKAGE_SUFFIX}")
#            else()
#                set(SUFFIX "-${component}")
#            endif()
#            
#            # PACKAGE_NAME
#            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME "${NAME}${SUFFIX}")
#            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME}" PARENT_SCOPE)
#            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME=${NAME}")
#            
#            # FILE_NAME
#            if(NOT DEFINED __TEMPLATE)
#                set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "DEB-DEFAULT")
#            else()
#                cpack_simple_eval(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "${__TEMPLATE}${SUFFIX}.deb")
#            endif()
#            set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "${CPACK_DEBIAN_${COMPONENT}_FILE_NAME}" PARENT_SCOPE)
#            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_FILE_NAME=${CPACK_DEBIAN_${COMPONENT}_FILE_NAME}")
#        endforeach()
#        
#        # PACKAGE_DEPENDS
#        foreach(component ${CPACK_COMPONENTS_ALL})
#            string(TOUPPER "${component}" COMPONENT)
#        
#            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${__DEPENDS})
#            foreach(dep ${CPACK_COMPONENT_${component}_DEPENDS})
#                string(TOUPPER "${dep}" DEP)
#                if(DEFINED CPACK_DEBIAN_${DEP}_PACKAGE_NAME)
#                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${CPACK_DEBIAN_${DEP}_PACKAGE_NAME})
#                else()
#                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${dep})
#                endif()
#            endforeach()
#            string(REPLACE ";" ", " CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
#            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}" PARENT_SCOPE)
#            __cpackutils_debug("    CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS=${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
#        endforeach()
#    endif()
endfunction(CPackDefineDEB)

