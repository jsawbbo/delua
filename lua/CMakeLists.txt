include_directories(
    ${PROJECT_BINARY_DIR}/include
    ${Lua_SOURCE_DIR}/src)

add_subdirectory(cmake)
add_subdirectory(src)
