/*
** DeLua Package Manager
** See Copyright Notice in version.h
*/
#ifndef pamlib_h
#define pamlib_h

#define PAM_VERSION_S "0.0"

#if defined(LUA_USE_WINDOWS)
extern inline int runasadmin() { return 0; }
#elif defined(LUA_USE_POSIX)
#include <sys/types.h>
#include <unistd.h>
extern inline int l_runasadmin(lua_State *L) { return getuid() == 0; }
#else
extern inline int l_runasadmin(lua_State *L) { return 0; }
#endif

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

#if defined(LUA_USE_WINDOWS)
#include <direct.h>
#define l_mkdir(L, dirname) ((void)L, _mkdir(dirname))
#else
#include <sys/stat.h>
#define l_mkdir(L, dirname) ((void)L, mkdir(dirname, 0700))
#endif

#endif
