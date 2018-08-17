// lua.hpp
// Lua header files for C++
// <<extern "C">> not supplied automatically because Lua also compiles as C++

#include "luaconf.h"
#if !defined(__lua_cplusplus)
extern "C" {
#endif
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#if !defined(__lua_cplusplus)
}
#endif
