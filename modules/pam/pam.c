#include "lauxlib.h"
#include "lua.h"

#include "pam.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>

LUA_API int lua_expandhome(lua_State *L, const char *filename);

static void pushexpanded(lua_State *L, const char *filename) {
  if (!lua_expandhome(L, filename))
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

static int getpath(lua_State *L) {
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
                    {"getpath", getpath},         //
                    {"interactive", interactive}, //
                    {NULL, NULL}};

struct Directory {
  const char *name;
  const char *path;
};

struct Directory pampaths[] = {
    {"prog", LUA_PROGDIR},                                               //
    {"progvdir", LUA_PROGDIR LUA_DIRSEP LUA_VDIR},                       //
    {"history", LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP "history"},   //
    {"cache", LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP "cache"},       //
    {"packages", LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP "packages"}, //
    {"ldir", LUA_HOME_LDIR},                                             //
    {"cdir", LUA_HOME_CDIR},                                             //
    {NULL, NULL}};

int buildref = LUA_NOREF;

LUAMOD_API int luaopen_pam(lua_State *L) {
  lua_getglobal(L, "package");

  /* set version information */
  lua_pushliteral(L, "_LUA_VERSION");
  lua_pushliteral(L, LUA_VERSION_MAJOR "." LUA_VERSION_MINOR);
  lua_settable(L, -3);

  lua_pushliteral(L, "_PAM_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  /* create pam paths table */
  lua_newtable(L);
#if defined(DEBUG)
  lua_pushliteral(L, "pampaths");
  lua_pushvalue(L, -2);
  lua_settable(L, -4);
#endif
  for (int i = 0; pampaths[i].name; i = i + 1) {
    lua_pushstring(L, pampaths[i].name);
    pushexpanded(L, pampaths[i].path);
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

  /* install functions */
  luaL_setfuncs(L, pamfn, 0);

  /* load modules */
  lua_getglobal(L, "require");

  /* - utilities */
  lua_pushvalue(L, -1);  /* require "pam.util" */
  lua_pushliteral(L, "pam.util");
  lua_call(L, 1, 0);

  /* - package database (quietly initialize) */
  lua_pushvalue(L, -1);  /* require "pam.db" */
  lua_pushliteral(L, "pam.db");
  lua_call(L, 1, 1);  /* -> db */

  // lua_getfield(L, -1, "clone");  /* db.clone(nil, { extra = "--quiet" }) */
  // lua_pushnil(L);
  // lua_createtable(L, 0, 1);
  // lua_pushliteral(L, "extra");
  // lua_pushliteral(L, "--quiet");
  // lua_rawset(L, -3);
  // lua_call(L, 2, 0);

  lua_pop(L, 1); /* remove "db" table */

  lua_pop(L, 1); /* remove "require" */

  return 1;
}
