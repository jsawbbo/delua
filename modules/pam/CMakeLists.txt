set(PAM_SCRIPTS 
    init.lua
    log.lua
    settings.lua
    command.lua
    exec.lua
    cmake.lua
    repository.lua
    package.lua)

install(FILES ${PAM_SCRIPTS}
    DESTINATION ${LUA_LDIR}/pam COMPONENT "pam")
