#include "luaconf.h"

#include <stdlib.h>
#include <stdio.h>
#if defined(DEBUG)

#define __D_PATH_SIZE 1024

void __d_lua_fill_path(char *dest, const char *envvar, const char *searchpath) {
    const char *envpath = getenv(envvar);
    if (envpath && *envpath)
        snprintf(dest, __D_PATH_SIZE, "%s" LUA_PATH_SEP "%s", envpath, searchpath);
    else
        snprintf(dest, __D_PATH_SIZE, "%s", searchpath);
}

static char __d_lua_path_buf[__D_PATH_SIZE] = {0};
const char *__d_lua_path() {
    if(__d_lua_path_buf[0] == 0)
       __d_lua_fill_path(__d_lua_path_buf, "LUA_PATH", LUA_PATH_DEFAULT_DIST);

	return __d_lua_path_buf;
}

static char __d_lua_cpath_buf[__D_PATH_SIZE] = {0};
const char *__d_lua_cpath() {
    if(__d_lua_cpath_buf[0] == 0)
       __d_lua_fill_path(__d_lua_cpath_buf, "LUA_PATH", LUA_CPATH_DEFAULT_DIST);

    return __d_lua_cpath_buf;
}

#endif /* DEBUG */
