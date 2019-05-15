macro(CPackSimpleDefineNSIS)
    if(WIN32)
#        set(CPACK_GENERATOR "NSIS" PARENT_SCOPE)
#
##        # Set name in installer and Add/Remove Program
##        set(CPACK_NSIS_PACKAGE_NAME "${_STYLED_NAME}" PARENT_SCOPE)
##        set(CPACK_NSIS_DISPLAY_NAME "${_STYLED_NAME}" PARENT_SCOPE)
##
##        # Set install and registry path
##        set(CPACK_PACKAGE_INSTALL_DIRECTORY "${_STYLED_NAME}" PARENT_SCOPE)
##
##        set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${_TARGET} PARENT_SCOPE)
##
##        # Add link to executable to Start menu
##        set(CPACK_PACKAGE_EXECUTABLES
##            "${_TARGET}" "${_STYLED_NAME}"
##            PARENT_SCOPE)
##
##        # Add license file and default contact info
##        if(_LICENSE_FILE)
##            set(CPACK_RESOURCE_FILE_LICENSE "${_LICENSE_FILE}" PARENT_SCOPE)
##        endif()
##        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT} PARENT_SCOPE)
##
##        # Ask if previous version should be uninstalled
##        set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON PARENT_SCOPE)
##
##        # Add website links to Start menu and installer
##        set(CPACK_NSIS_MENU_LINKS
##            "http:////neurosuite.github.io" "Homepage of ${_STYLED_NAME}" PARENT_SCOPE)
##        set(CPACK_NSIS_URL_INFO_ABOUT
##            "https:////neurosuite.github.io"
##            PARENT_SCOPE)
##        set(CPACK_NSIS_HELP_LINK
##            "https:////neurosuite.github.io//information.html"
##            PARENT_SCOPE)
##
##        # Fix package name and install root depending on architecture
##        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
##            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64"  PARENT_SCOPE)
##            set(CPACK_SYSTEM_NAME "win64" PARENT_SCOPE)
##        else()
##            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES32"  PARENT_SCOPE)
##            set(CPACK_SYSTEM_NAME "win32" PARENT_SCOPE)
##        endif()
    endif()
endmacro()
