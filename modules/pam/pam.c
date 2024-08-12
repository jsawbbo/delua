#include "lauxlib.h"
#include "lua.h"

#include "version.h"

#include <stdlib.h>

LUA_API int lua_expandhome(lua_State *L, const char *filename);

static void pushexpanded(lua_State *L, const char *filename) {
  if (!lua_expandhome(L, filename))
    lua_pushstring(L, filename);
}

#if defined(LUA_USE_WINDOWS)
static int runasadmin() { return 0; }
#elif defined(LUA_USE_POSIX)
#include <sys/types.h>
#include <unistd.h>

static int runasadmin() { return getuid() == 0; }
#else
static int runasadmin() { return 0; }
#endif

static int isadmin(lua_State *L) {
  lua_pushboolean(L, runasadmin());
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

struct Directory {
  const char *name;
  const char *path;
};

struct Directory builddirs[] = {
    {"prog", LUA_PROGDIR},                                             //
    {"progvdir", LUA_PROGDIR LUA_DIRSEP LUA_VDIR},                     //
    {"history", LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP "history"}, //
    {"cache", LUA_PROGDIR LUA_DIRSEP "cache" LUA_DIRSEP LUA_VDIR},     //
    {"ldir", LUA_HOME_LDIR},                                           //
    {"cdir", LUA_HOME_CDIR},                                           //
    {NULL, NULL}};

int buildref = LUA_NOREF;

LUAMOD_API int luaopen_pam(lua_State *L) {
  lua_getglobal(L, "package");

  lua_pushliteral(L, "_PAM_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  lua_newtable(L);
#if defined(DEBUG)
  lua_pushliteral(L, "build");
  lua_pushvalue(L, -2);
  lua_settable(L, -4);
#endif
  for (int i = 0; builddirs[i].name; i = i + 1) {
    lua_pushstring(L, builddirs[i].name);
    pushexpanded(L, builddirs[i].path);
    lua_settable(L, -3);
  }
  if (runasadmin()) {
    lua_pushliteral(L, "ldir");
    lua_pushliteral(L, LUA_LDIR);
    lua_settable(L, -3);
    lua_pushliteral(L, "cdir");
    lua_pushliteral(L, LUA_CDIR);
    lua_settable(L, -3);
  }
  buildref = luaL_ref(L, LUA_REGISTRYINDEX);

  luaL_setfuncs(L, pamfn, 0);

  lua_getglobal(L, "require");
  lua_pushvalue(L, -1);
  lua_pushliteral(L, "pam.util");
  lua_call(L, 1, 0);
  lua_pop(L, 1);

  return 1;
}
