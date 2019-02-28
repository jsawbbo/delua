include_directories(
    ${PROJECT_BINARY_DIR}/include
    ${Lua_SOURCE_DIR}/src)

if(LUA_LANGUAGE_C)
    add_subdirectory(src)
endif()
if(LUA_LANGUAGE_CXX)
    add_subdirectory(srcpp)
endif()
