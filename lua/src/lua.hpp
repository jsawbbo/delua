// lua.hpp
// Lua header files for C++
// <<extern "C">> not supplied automatically because Lua also compiles as C++

#if !defined(DELUA_LANGUAGE_CXX)
extern "C" {
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#if !defined(DELUA_LANGUAGE_CXX)
}
#endif
