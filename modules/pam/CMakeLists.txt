set(PAM_SCRIPTS 
    init.lua
    options.lua
    db.lua)

install(FILES ${PAM_SCRIPTS}
    DESTINATION ${DeLua_PATH_DIR}/pam COMPONENT "pam")
