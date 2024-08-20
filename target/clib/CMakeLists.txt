# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets DeLuaCLibStatic)
    add_library(DeLuaCLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCLibStatic
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_PROGNAME}-${DeLua_RELEASE})
    target_include_directories(DeLuaCLibStatic PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCLibStatic
	    PUBLIC DELUA_LANGUAGE_C DELUA_VERSION=${DeLua_VERSION_NUM}
    )
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets DeLuaCLib)
    add_library(DeLuaCLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    target_link_libraries(DeLuaCLib ${CMAKE_DL_LIBS})
    set_target_properties(DeLuaCLib
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_PROGNAME}-${DeLua_RELEASE}
            VERSION ${DeLua_VERSION}
            SOVERSION ${DeLua_VERSION_MAJOR})
    target_include_directories(DeLuaCLib PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCLib
        PUBLIC DELUA_LANGUAGE_C DELUA_VERSION=${DeLua_VERSION_NUM}
    )
endif()

if(LUA_BUILD_SHARED)
    add_library(DeLua::Library ALIAS DeLuaCLib)
    add_library(DeLua::Library::C ALIAS DeLuaCLib)
    set_target_properties(DeLuaCLib
        PROPERTIES
	        EXPORT_NAME DeLua::Library::C)
elseif()
    add_library(DeLua::Library::C ALIAS DeLuaCLibStatic)
    set_target_properties(DeLuaCLibStatic
        PROPERTIES
	        EXPORT_NAME DeLua::Library::C)
endif()

if(LUA_BUILD_INTERPRETER)
    add_executable(LuaInterpreter ${executable_options} ${LUA_SRCS})
    if (DeLua_SYMBOLIC_LINK)
        set_target_properties(LuaInterpreter
            PROPERTIES
                LINKER_LANGUAGE C
                VERSION ${DeLua_RELEASE}
                OUTPUT_NAME ${LUA_PROGNAME})
    else()
        set_target_properties(LuaInterpreter
            PROPERTIES
                LINKER_LANGUAGE C
                OUTPUT_NAME ${LUA_PROGNAME}-${DeLua_RELEASE})
    endif()
    target_link_libraries(LuaInterpreter DeLuaCLib ${LUA_READLINE_LIBRARY})
endif()

if(LUA_BUILD_COMPILER)
    add_executable(LuaCompiler ${executable_options} ${LUAC_SRCS})
    if (DeLua_SYMBOLIC_LINK)
        set_target_properties(LuaCompiler
            PROPERTIES
                LINKER_LANGUAGE C
                VERSION ${DeLua_RELEASE}
                OUTPUT_NAME ${LUA_PROGNAME}c)
    else()
        set_target_properties(LuaCompiler
            PROPERTIES
                LINKER_LANGUAGE C
                OUTPUT_NAME ${LUA_PROGNAME}c-${DeLua_RELEASE})
    endif()
    target_link_libraries(LuaCompiler DeLuaCLib)
endif()

# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeLuaTargets-${DeLua_RELEASE}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT "runtime"
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT "development"
)

if(LUA_BUILD_INTERPRETER)
    install(TARGETS LuaInterpreter
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "runtime")
endif()

if(LUA_BUILD_COMPILER)
    install(TARGETS LuaCompiler
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "runtime")
endif()

