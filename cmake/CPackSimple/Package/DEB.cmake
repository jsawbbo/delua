include(CPackSimple/UnixUtils)

# TODO 
#     CPACK_DEBIAN_PACKAGE_HOMEPAGE
# see also https://cmake.org/cmake/help/v3.10/module/CPackDeb.html
macro(cpack_simple_package_deb)
	if(UNIX AND NOT APPLE)
		cmake_parse_arguments(__deb "" "DISTRIBUTION;TEMPLATE;MAINTAINER;SCRIPTS;GROUP" "DEPENDS;SUGGESTS;RECOMMENDS;BREAKS;CONFLICTS;COMPONENTS" ${ARGN})
		
		if(NOT __deb_DISTRIBUTION)
			set(__deb_DISTRIBUTION "Debian")
		endif()
		cpack_simple_unix_sysinfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)

		if(DISTRIBUTION MATCHES ${__deb_DISTRIBUTION})
			# === [[ GENERATOR DEFAULTS ]]
			cpack_simple_set(CPACK_GENERATOR "DEB")
			cpack_simple_set(CPACK_DEB_COMPONENT_INSTALL TRUE)
			
			cpack_simple_set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CPACK_PACKAGE_HOMEPAGE}")
			cpack_simple_set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${ARCHITECTURE})

			# MAINTAINER
			if(NOT __deb_MAINTAINER)
			    set(__deb_MAINTAINER "${CPACK_PACKAGE_CONTACT}")
			endif()
			cpack_simple_set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${__deb_MAINTAINER}")
	
			# GROUP
			if(NOT __deb_GROUP)
				set(__deb_GROUP ${CPACK_SIMPLE_PACKAGE_GROUP})
			endif()
			cpack_simple_set(CPACK_DEBIAN_PACKAGE_SECTION ${__deb_GROUP})
			
	        # BUILD_DEPENDS;DEPENDS;SUGGESTS;CONFICTS;BREAKS
	        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_DEPENDS "${__deb_DEPENDS}")
	        cpack_simple_set(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}")
	
	        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_RECOMMENDS "${__deb_RECOMMENDS}")
	        cpack_simple_set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "${CPACK_DEBIAN_PACKAGE_RECOMMENDS}")
	
	        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_SUGGESTS "${__deb_SUGGESTS}")
	        cpack_simple_set(CPACK_DEBIAN_PACKAGE_SUGGESTS "${CPACK_DEBIAN_PACKAGE_SUGGESTS}")
	
	        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_BREAKS "${__deb_BREAKS}")
	        cpack_simple_set(CPACK_DEBIAN_PACKAGE_BREAKS "${CPACK_DEBIAN_PACKAGE_BREAKS}")
	
	        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_CONFLICTS "${__deb_CONFLICTS}")
	        cpack_simple_set(CPACK_DEBIAN_PACKAGE_CONFLICTS "${CPACK_DEBIAN_PACKAGE_CONFLICTS}")
			
			# SCRIPTS
	        if(SCRIPTS)
	            foreach(SCRIPT shlibs postinst prerm postrm)
	                if(EXISTS "${__deb_SCRIPTS}/${SCRIPT}")
	                    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${__deb_SCRIPTS}/${SCRIPT}")
	                endif()
	            endforeach()
	            
	            cpack_simple_set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA} PARENT_SCOPE)
	        endif()
			
			# TEMPLATE
			if(NOT __deb_TEMPLATE)
				if(DISTRIBUTION MATCHES Ubuntu)
					set(__deb_TEMPLATE "\${NAME}_\${VERSION}-${DEB_VERSION}ubuntu${UBUNTU_RELEASE}_\${ARCHITECTURE}")
				endif()
			endif()

	        set(NAME ${CPACK_PACKAGE_NAME})
	        set(VERSION ${CPACK_PACKAGE_VERSION})
	        if(NOT DEFINED __deb_TEMPLATE)
	            set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
	        else()
	            cpack_simple_eval(CPACK_DEBIAN_FILE_NAME "${__deb_TEMPLATE}.deb")
	        endif()
            cpack_simple_set(CPACK_DEBIAN_FILE_NAME "${CPACK_DEBIAN_FILE_NAME}")
			
			# COMPONENTS
			if(__deb_COMPONENTS)
				cpack_simple_configure_components(${__deb_COMPONENTS})
			endif()
			
	        cpack_simple_set(CPACK_DEB_PACKAGE_COMPONENT TRUE)
	        foreach(component ${CPACK_COMPONENTS_ALL})
	            string(TOUPPER "${component}" COMPONENT)
	            
	            if(DEFINED CPACK_COMPONENT_${component}_PACKAGE_SUFFIX)
	                set(SUFFIX "${CPACK_COMPONENT_${component}_PACKAGE_SUFFIX}")
	            else()
	                set(SUFFIX "-${component}")
	            endif()
	            
	            # PACKAGE_NAME
	            cpack_simple_set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME "${NAME}${SUFFIX}")
	            
	            # FILE_NAME
	            if(NOT DEFINED __deb_TEMPLATE)
	                cpack_simple_set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "DEB-DEFAULT")
	            else()
	                cpack_simple_eval(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "${__deb_TEMPLATE}${SUFFIX}.deb")
	                cpack_simple_set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME ${CPACK_DEBIAN_${COMPONENT}_FILE_NAME})
	            endif()

				# DEPENDS
	            set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${__deb_DEPENDS})
	            foreach(dep ${CPACK_COMPONENT_${component}_DEPENDS})
	                string(TOUPPER "${dep}" DEP)
	                if(DEFINED CPACK_DEBIAN_${DEP}_PACKAGE_NAME)
	                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${CPACK_DEBIAN_${DEP}_PACKAGE_NAME})
	                else()
	                    list(APPEND CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS ${dep})
	                endif()
	            endforeach()
	            string(REPLACE ";" ", " CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
	            cpack_simple_set(CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_DEPENDS}")
	        endforeach()
		endif()
	endif()
endmacro()
