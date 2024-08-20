file(GLOB PAM_SCRIPTS
    "*.lua"
    "*/*.lua"
)

foreach(PAMSCRIPT IN LISTS PAM_SCRIPTS)
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" SCRIPT ${PAMSCRIPT})
    string(REGEX REPLACE "/.*" "" SCRIPTDIR ${SCRIPT})
    if(${SCRIPT} STREQUAL ${SCRIPTDIR})
        install(FILES ${SCRIPT}
            DESTINATION ${LUA_LDIR}/pam COMPONENT "pam")
    else()
        install(FILES ${SCRIPT}
            DESTINATION ${LUA_LDIR}/pam/${SCRIPTDIR} COMPONENT "pam")
    endif()
endforeach()

