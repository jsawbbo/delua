
function(CPackDefineDMG)
    if(APPLE)
#        set(CPACK_GENERATOR "DragNDrop" PARENT_SCOPE)
#        set(CPACK_DMG_FORMAT "UDBZ" PARENT_SCOPE)
#        set(CMAKE_INSTALL_PREFIX "/Applications" PARENT_SCOPE)
#        set(CPACK_SYSTEM_NAME "osx-${CMAKE_SYSTEM_PROCESSOR}" PARENT_SCOPE)
    endif()
endfunction()

