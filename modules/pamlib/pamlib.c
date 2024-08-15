#include "lauxlib.h"
#include "lua.h"

#include "pamlib.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>

static void pushexpanded(lua_State *L, const char *filename) {
  if (lua_expandhome(L, filename))
    return;
  lua_pushstring(L, filename);
}

/** Check if running with administrator rights.
 * ::as.lua
 *    pam.runasadmin()
 * ::returns
 *    `true` is program is run with administrator priviledges, `false`
 * otherwise.
 */
static int runasadmin(lua_State *L) {
  lua_pushboolean(L, l_runasadmin(L));
  return 1;
}

/** Get or change current working directory.
 * ::as.lua
 *    pam.workdir()
 *    pam.workdir(directory)
 * ::returns
 *    This function returns the current working directory.
 *
 * This function is required until `pam` is bootstrapped.
 *
 */
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

/** Check if we have an interactive standard input.
 * ::as.lua
 *      pam.interactive()
 * ::returns
 *      `true` if ''stdin'' is a terminal (i.e. interactive), `false` otherwise.
 *
 * This functions retri
 */
static int interactive(lua_State *L) {
  lua_pushboolean(L, lua_stdin_is_tty());
  return 1;
}

struct Config {
  const char *key;
  const char *value;
  const char *brief;
};

struct Config pamconfig[] = {
    {"dirsep", LUA_DIRSEP, "directory separator character"},            //
    {"progdir", LUA_PROGDIR, "program directory in users home folder"}, //
    {"vdir", LUA_VDIR, "version directory (e.g. '5.4')"},               //
    {"root", LUA_ROOT, "installation root"},                            //
    {"home", LUA_LOCAL, "user's local installation path"},              //
    {"ldir", LUA_LDIR, "module directory (script path)"},               //
    {"cdir", LUA_CDIR, "module direcotry (compiled modules)"},          //
    {NULL, NULL, NULL}};

luaL_Reg pamreg[] = {{"runasadmin", runasadmin},   //
                     {"workdir", workdir},         //
                     {"interactive", interactive}, //
                     {NULL, NULL}};

int configref = LUA_NOREF;

LUAMOD_API int luaopen_pamlib(lua_State *L) {
  lua_newtable(L);
  lua_pushvalue(L, -1);
  lua_setglobal(L, "pam");

  /* init directories */
  if (!lua_expandhome(L, LUA_PROGDIR))
    lua_pushliteral(L, LUA_PROGDIR);
  if ((l_mkdir(L, lua_tostring(L, -1)) == 0) || (errno = EEXIST)) {
    if (!lua_expandhome(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR))
      lua_pushliteral(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR);
    if ((l_mkdir(L, lua_tostring(L, -1)) == 0) || (errno = EEXIST)) {
      const char *dirs[] = {"db", "cache", "build", NULL};
      if (!lua_expandhome(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP))
        lua_pushliteral(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR);

      for (int i = 0; dirs[i]; i++) {
        lua_pushvalue(L, -1);
        lua_pushstring(L, dirs[i]);
        lua_concat(L, 2);
        l_mkdir(L, lua_tostring(L, -1));
        lua_pop(L, 1);
      }

      lua_pop(L, 1);
    }
    lua_pop(L, 1);
  }
  lua_pop(L, 1);

  /* set version information */
  lua_pushliteral(L, "_VERSION");
  lua_pushliteral(L, PAM_VERSION_S);
  lua_settable(L, -3);

  /* create pam config table */
  lua_newtable(L);
  for (int i = 0; pamconfig[i].key; i = i + 1) {
    lua_pushstring(L, pamconfig[i].key);
    pushexpanded(L, pamconfig[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "config");

  /* install functions */
  luaL_setfuncs(L, pamreg, 0);

  return 1;
}
