#include "lauxlib.h"
#include "lua.h"

#include "version.h"

#include <stdlib.h>

LUA_API int lua_expandhome(lua_State *L, const char *filename);

static void pushexpanded(lua_State *L, const char *filename) {
  if (!lua_expandhome(L, filename))
    lua_pushstring(L, filename);
}

static int isadmin(lua_State *L) {
  int admin = 0;

  // FIXME

  lua_pushboolean(L, admin);
  return 1;
}

static int interactive(lua_State *L) {
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

  lua_pushboolean(L, lua_stdin_is_tty());
  return 1;
}

luaL_Reg pamfn[] = {{"isadmin", isadmin},         //
                    {"interactive", interactive}, //
                    {NULL, NULL}};

struct Path {
  const char *name;
  const char *directory;
};

struct Path builddirs[] = {
    {"progdir", LUA_PROGDIR},                                          //
    {"history", LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP "history"}, //
    {"cachedir", LUA_PROGDIR LUA_DIRSEP "cache" LUA_DIRSEP LUA_VDIR},  //
    {NULL, NULL}};

LUAMOD_API int luaopen_pam(lua_State *L) {
  lua_getglobal(L, "package");

  lua_pushliteral(L, "_PAM_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  lua_newtable(L);
  lua_pushliteral(L, "build");
  lua_pushvalue(L, -2);
  lua_settable(L, -4);
  for (int i = 0; builddirs[i].name; i = i + 1) {
    lua_pushstring(L, builddirs[i].name);
    pushexpanded(L, builddirs[i].directory);
    lua_settable(L, -3);
  }
  lua_pop(L, 1);

  luaL_setfuncs(L, pamfn, 0);

  return 1;
}
