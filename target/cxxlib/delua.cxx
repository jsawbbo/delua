#include "delua.hpp"

#if !defined(DELUA_LANGUAGE_CXX)
extern "C" {
#endif
//
#if !defined(DELUA_LANGUAGE_CXX)
}
#endif

lua_Exception::lua_Exception(lua_State *L, const char *message)
    : std::exception(), L_(L), status_(LUA_ERRRUN)
{
  lua_pushstring(L, message);
}

const char *lua_Exception::what() const noexcept {
    return "unhandled exception escaped the Lua VM";
}
