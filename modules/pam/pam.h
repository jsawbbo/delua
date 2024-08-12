/*
** DeLua Package Manager
** See Copyright Notice in version.h
*/
#ifndef pam_pam_h
#define pam_pam_h

#include "version.h"

#if defined(LUA_USE_WINDOWS)
extern inline int runasadmin() { return 0; }
#elif defined(LUA_USE_POSIX)
#include <sys/types.h>
#include <unistd.h>

extern inline int runasadmin() { return getuid() == 0; }
#else
extern inline int runasadmin() { return 0; }
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

extern int buildref;

#endif
