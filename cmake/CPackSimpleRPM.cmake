include(CPackSimpleUnix)

##[=======================================================================[.rst:
#CPackDefineRPM
#
#Defined RPM (Redhat) package.
#
#.. command: CPackDefineRPM
#
#    ::
#        CPackDefineRPM(
#        )
#
##]=======================================================================]
#function(CPackDefineRPM _DIST_NAME)
#    cpack_simple_unix_sysinfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)
#
#    if(DISTRIBUTION MATCHES ${_DIST_NAME})
##        set(CPACK_GENERATOR "RPM" PARENT_SCOPE)
##
##        # Set defaults
##        set(CPACK_RPM_PACKAGE_GROUP "Science" PARENT_SCOPE)
##        set(CPACK_RPM_PACKAGE_LICENSE "GPLv2" PARENT_SCOPE)
##        set(CPACK_RPM_PACKAGE_URL "http://neurosuite.github.io" PARENT_SCOPE)
##
##        # Set architecture
##        set(CPACK_RPM_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)
##
##        # Set dependencies
##        set(CPACK_RPM_PACKAGE_REQUIRES ${_REQUIRES} PARENT_SCOPE)
##
##        # Determine suggested packages
##        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
##        string(REPLACE ";" ", "
##               CPACK_RPM_PACKAGE_SUGGESTS
##               "${GEN_SUGGESTED_PACKAGES}")
##        set(CPACK_RPM_PACKAGE_SUGGESTS
##            "${CPACK_RPM_PACKAGE_SUGGESTS}"
##            PARENT_SCOPE)
##
##        # Add script if path supplied
##        if(_SCRIPT_DIR)
##            if(EXIST "${_SCRIPT_DIR}/postinst")
##                set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE
##                    "${_SCRIPT_DIR}/postinst"
##                    PARENT_SCOPE)
##            endif()
##            if(EXIST "${_SCRIPT_DIR}/postrm")
##                set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE
##                    "${_SCRIPT_DIR}/postrm"
##                    PARENT_SCOPE)
##            endif()
##        endif()
##
##        # Determine package name
##        set(NAME ${CPACK_PACKAGE_NAME})
##        set(VERSION ${CPACK_PACKAGE_VERSION})
##        gen_eval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
#    endif()
#endfunction(CPackDefineRPM)
