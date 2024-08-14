set(PAM_SCRIPTS 
    init.lua
    log.lua
    settings.lua
    command.lua
    db.lua)

install(FILES ${PAM_SCRIPTS}
    DESTINATION ${DeLua_PATH_DIR}/pam COMPONENT "pam")
