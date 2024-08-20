#include "lauxlib.h"
#include "lua.h"

#include "pamlib.h"
#include "sysinfo.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>

static void pushexpanded(lua_State *L, const char *filename)
{
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
static int runasadmin(lua_State *L)
{
  lua_pushboolean(L, pam_runasadmin());
  return 1;
}

/** Get current working directory.
 * ::as.lua
 *    pam.getcwd()
 * ::returns
 *    This function returns the current working directory.
 */
static int current_directory(lua_State *L)
{
  char cwd[PATH_MAX];

  lua_pushstring(L, pam_getcwd(cwd, PATH_MAX));

  return 1;
}

/** Change current working directory.
 * ::as.lua
 *    pam.workdir()
 *    pam.workdir(directory)
 * ::returns
 *    This function returns the current working directory.
 *
 * This function is required until `pam` is bootstrapped.
 *
 */
static int change_directory(lua_State *L)
{
  const char *path = luaL_optstring(L, 1, ".");

  current_directory(L);

  if (pam_chdir(path) != 0)
  {
    luaL_error(L, "Couldn't change working directory: %s", strerror(errno));
  }

  return 1;
}

/** Check if we have an interactive standard input.
 * ::as.lua
 *      pam.isatty(stream)
 * ::returns
 *      `true` if ''stream'' is a TTY, `false` otherwise.
 */
static int is_a_tty(lua_State *L)
{
  luaL_Stream *stream = (luaL_Stream *)luaL_checkudata(L, 1, LUA_FILEHANDLE);
  if (stream->closef == NULL)
    lua_pushboolean(L, 0);
  else
    lua_pushboolean(L, pam_isatty(stream->f));
  return 1;
}

struct KVPair
{
  const char *key;
  const char *value;
};

struct KVPair pamconfig[] = {
    {"dirsep", LUA_DIRSEP},   /* alternative to 'package.config:sub(1,1)' */
    {"progdir", LUA_PROGDIR}, /* program directory in the user's home (e.g. "~/.local") */
    {"vdir", LUA_VDIR},       /* the versioned sub-directory part (release) */
    {"root", LUA_ROOT},       /* installation prefix */
    {"home", LUA_LOCAL},      /* user specific installation prefix */
    {"ldir", LUA_LDIR},       /* Lua module sub-directory */
    {"cdir", LUA_CDIR},       /* compiled module sub-directory */
    {"lua_version", LUA_VERSION_MAJOR "." LUA_VERSION_MINOR "." LUA_VERSION_RELEASE},
    {NULL, NULL}};

struct KVPair pamos[] = DELUA_PAM_OS; /* this contains the entries:  */
                                      /* name: operating system name (e.g. "Linux") */
                                      /* release: operating system release (e.g. "6.5.0-1027-oem") */
                                      /* version: detailed version info (e.g. "#28-Ubuntu SMP PREEMPT_DYNAMIC Thu Jul
                                       * 25 13:32:46 UTC 2024") */
                                      /* platform: operating system platform (e.g. "x86_64") */

struct KVPair pamdistro[] =
    DELUA_PAM_DISTRO; /* this contains the entries (if applicable): */
                      /* id: operating system ID (e.g. "ubuntu") */
                      /* like: operating system similarity (e.g. "debian") */
                      /* name: operating system name (e.g. "Ubuntu") */
                      /* codename: the operating system's codename (e.g. "jammy") */
                      /* pretty: "pretty-formatted" operating system designation (e.g "Ubuntu 22.04.4
                       * LTS") */

luaL_Reg pamreg[] = {{"runasadmin", runasadmin},    //
                     {"getcwd", current_directory}, //
                     {"chdir", change_directory},   //
                     {"isatty", is_a_tty},          //
                     {NULL, NULL}};

LUAMOD_API int luaopen_pamlib(lua_State *L)
{
  lua_newtable(L);
  lua_pushvalue(L, -1);
  lua_setglobal(L, "pam");

  /* init directories */
  pushexpanded(L, LUA_PROGDIR);
  if ((pam_mkdir(lua_tostring(L, -1)) == 0) || (errno = EEXIST))
  {
    pushexpanded(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR);
    if ((pam_mkdir(lua_tostring(L, -1)) == 0) || (errno = EEXIST))
    {
      const char *dirs[] = {"repo", "cache", "build", NULL};

      pushexpanded(L, LUA_PROGDIR LUA_DIRSEP LUA_VDIR LUA_DIRSEP);
      for (int i = 0; dirs[i]; i++)
      {
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
  for (int i = 0; pamconfig[i].key; i = i + 1)
  {
    lua_pushstring(L, pamconfig[i].key);
    pushexpanded(L, pamconfig[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "config");

  /* create pam os table */
  lua_newtable(L);
  for (int i = 0; pamos[i].key; i = i + 1)
  {
    lua_pushstring(L, pamos[i].key);
    pushexpanded(L, pamos[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "os");

  /* create pam distro table */
  lua_newtable(L);
  for (int i = 0; pamdistro[i].key; i = i + 1)
  {
    lua_pushstring(L, pamdistro[i].key);
    pushexpanded(L, pamdistro[i].value);
    lua_settable(L, -3);
  }
  lua_setfield(L, -2, "distro");

  /* install functions */
  luaL_setfuncs(L, pamreg, 0);

  return 1;
}
