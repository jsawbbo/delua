#include "lauxlib.h"
#include "lua.h"

#include "pamlib.h"
#include "sysinfo.h"

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
  lua_pushboolean(L, pam_runasadmin());
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
  const char *newdir = luaL_optstring(L, 1, NULL);
  char cwd[PATH_MAX];

  lua_pushstring(L, pam_getcwd(cwd, PATH_MAX));
  if (newdir) {
    if (pam_chdir(newdir) != 0)
      luaL_error(L, "Couldn't change working directory: %s", strerror(errno));
  }

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
  lua_pushboolean(L, pam_stdin_isatty());
  return 1;
}

struct KVPair {
  const char *key;
  const char *value;
};

struct KVPair pamconfig[] = {{"dirsep", LUA_DIRSEP},   //
                             {"progdir", LUA_PROGDIR}, //
                             {"vdir", LUA_VDIR},       //
                             {"root", LUA_ROOT},       //
                             {"home", LUA_LOCAL},      //
                             {"ldir", LUA_LDIR},       //
                             {"cdir", LUA_CDIR},       //
                             {NULL, NULL }};

struct KVPair pamos[] = DELUA_PAM_OS;

struct KVPair pamdistro[] = DELUA_PAM_DISTRO;

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
  if ((pam_mkdir(lua_tostring(L, -1)) == 0) || (errno = EEXIST)) {
    if (!lua_expandhome(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR))
      lua_pushliteral(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR);
    if ((pam_mkdir(lua_tostring(L, -1)) == 0) || (errno = EEXIST)) {
      const char *dirs[] = {"repo", "cache", "build", NULL};
      if (!lua_expandhome(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP))
        lua_pushliteral(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR);

      for (int i = 0; dirs[i]; i++) {
        lua_pushvalue(L, -1);
        lua_pushstring(L, dirs[i]);
        lua_concat(L, 2);
        pam_mkdir(lua_tostring(L, -1));
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

  /* create pam os table */
  lua_newtable(L);
  for (int i = 0; pamos[i].key; i = i + 1) {
    lua_pushstring(L, pamos[i].key);
    pushexpanded(L, pamos[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "os");

  /* create pam distro table */
  lua_newtable(L);
  for (int i = 0; pamdistro[i].key; i = i + 1) {
    lua_pushstring(L, pamdistro[i].key);
    pushexpanded(L, pamdistro[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "distro");

  /* install functions */
  luaL_setfuncs(L, pamreg, 0);

  return 1;
}
