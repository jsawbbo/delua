#include "lauxlib.h"
#include "lua.h"

#include "version.h"

#include <stdlib.h>

/* from lua.c: */
#if !defined(lua_stdin_is_tty) /* { */

#if defined(LUA_USE_POSIX) /* { */

#include <unistd.h>
#define lua_stdin_is_tty() isatty(0)

#elif defined(LUA_USE_WINDOWS) /* }{ */

#include <io.h>
#include <windows.h>

#define lua_stdin_is_tty() _isatty(_fileno(stdin))

#else                        /* }{ */

/* ISO C definition */
#define lua_stdin_is_tty() 1 /* assume stdin is a tty */

#endif /* } */

#endif /* } */

static int isadmin(lua_State *L) { return 1; }

static int cachedir(lua_State *L) {
  luaL_Buffer path;
  luaL_buffinit(L, &path);

  if (*LUA_CACHEDIR == *LUA_HOME_MARK) {
#if defined(LUA_USE_WINDOWS)
    luaL_addstring(&path, getenv("USERPROFILE"));
#else
    luaL_addstring(&path, getenv("HOME"));
#endif
    luaL_addstring(&path, &LUA_CACHEDIR[1]);
  } else {
    luaL_addstring(&path, LUA_CACHEDIR);
  }

  luaL_pushresult(&path);
  return 1;
}

static int interactive(lua_State *L) {
  lua_pushboolean(L, lua_stdin_is_tty());
  return 1;
}

luaL_Reg pamfn[] = {{"isadmin", isadmin},
                    {"cachedir", cachedir},
                    {"interactive", interactive},
                    {NULL, NULL}};

LUAMOD_API int luaopen_pam(lua_State *L) {
  lua_getglobal(L, "package");

  luaL_setfuncs(L, pamfn, 0);

  lua_pushliteral(L, "_PAM_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  return 1;
}
