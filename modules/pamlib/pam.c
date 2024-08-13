#include "lauxlib.h"
#include "lua.h"

#include "pam.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>

LUA_API int lua_expandhome(lua_State *L, const char *filename);

static void pushexpanded(lua_State *L, const char *filename) {
  if (lua_expandhome(L, filename))
    return;
  lua_pushstring(L, filename);
}

static int isadmin(lua_State *L) {
  lua_pushboolean(L, runasadmin());
  return 1;
}

static int workdir(lua_State *L) {
  int havepath = lua_gettop(L) > 0;
#if defined(LUA_USE_POSIX)
  char cwd[PATH_MAX];
#endif

  if (havepath) {
    if (lua_gettop(L) != 1)
      luaL_error(L, "expected a single string argument");
    luaL_checktype(L, 1, LUA_TSTRING);
  }

#if defined(LUA_USE_POSIX)
  lua_pushstring(L, getcwd(cwd, PATH_MAX));
  if (havepath) {
    if (chdir(lua_tostring(L, 1)) != 0)
      luaL_error(L, "Couldn't change working directory: %s", strerror(errno));
  }
#else
#error Not implemented
#endif

  return 1;
}

static int interactive(lua_State *L) {
  lua_pushboolean(L, lua_stdin_is_tty());
  return 1;
}

static int config(lua_State *L) {
  if (lua_gettop(L) != 1)
    luaL_error(L, "expected a single string argument");
  luaL_checktype(L, 1, LUA_TSTRING);

  lua_rawgeti(L, LUA_REGISTRYINDEX, buildref);
  lua_rotate(L, 1, 1);

  lua_rawget(L, -2);
  return 1;
}

luaL_Reg pamfn[] = {{"isadmin", isadmin},         //
                    {"workdir", workdir},         //
                    {"config", config},           //
                    {"interactive", interactive}, //
                    {NULL, NULL}};

struct Directory {
  const char *name;
  const char *path;
};

struct Directory pampaths[] = {{"vdir", LUA_VDIR},          //
                               {"progdir", LUA_PROGDIR},    //
                               {"root", LUA_ROOT},          //
                               {"ldir", LUA_LDIR},          //
                               {"cdir", LUA_CDIR},          //
                               {"home", LUA_HOME},          //
                               {"homeldir", LUA_HOME_LDIR}, //
                               {"homecdir", LUA_HOME_CDIR}, //
                               {NULL, NULL}};

int buildref = LUA_NOREF;

LUAMOD_API int luaopen_pamlib(lua_State *L) {
  lua_newtable(L);
  lua_pushvalue(L, -1);
  lua_setglobal(L, "pam");

  /* set version information */
  lua_pushliteral(L, "_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  /* create pam paths table */
  lua_newtable(L);
#if defined(DEBUG)
  lua_pushliteral(L, "pamconfig");
  lua_pushvalue(L, -2);
  lua_settable(L, -4);
#endif
  for (int i = 0; pampaths[i].name; i = i + 1) {
    lua_pushstring(L, pampaths[i].name);
    pushexpanded(L, pampaths[i].path);
    lua_settable(L, -3);
  }

  buildref = luaL_ref(L, LUA_REGISTRYINDEX);

  /* install functions */
  luaL_setfuncs(L, pamfn, 0);

  return 1;
}
