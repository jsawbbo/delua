/*
** DeLua Package Manager
** See Copyright Notice in version.h
*/
#include "lauxlib.h"
#include "lua.h"
#include "pamlib.h"

#define EXIT_FAILURE 1 /* Failing exit status.  */
#define EXIT_SUCCESS 0 /* Successful exit status.  */

/*
** Prints an error message, adding the program name in front of it
** (if present)
*/
static void l_message(const char *pname, const char *msg) {
  if (pname)
    lua_writestringerror("%s: ", pname);
  lua_writestringerror("%s\n", msg);
}

LUALIB_API void luaL_openlibs(lua_State *L);

int main(int argc, char **argv) {
  lua_State *L = luaL_newstate(); /* create state */
  if (L == NULL) {
    l_message(argv[0], "cannot create state: not enough memory");
    return EXIT_FAILURE;
  }
  luaL_checkversion(L); /* check that interpreter has correct version */
  luaL_openlibs(L);     /* open standard libraries */

  lua_getglobal(L, "require");  /* load pam library */
  lua_pushliteral(L, "pam");
  lua_call(L, 1, 1);

  for(int i=1; i<=argc; ++i)    /* run pam(...) command */
    lua_pushstring(L, argv[i]);
  lua_call(L, argc, 0);

  return EXIT_SUCCESS;
}
