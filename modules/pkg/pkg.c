#include "lua.h"
#include "lauxlib.h"

static const luaL_Reg pk_funcs[] = {
  {"add", NULL},
  {"remove", NULL},
  {"update", NULL},
  {NULL, NULL}
};

LUAMOD_API int luaopen_pkg (lua_State *L) {
  luaL_newlib(L, pk_funcs);
  lua_pushvalue(L, -1);
  lua_setglobal(L, "pkg");
  return 1;
}