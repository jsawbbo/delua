/*
** $Id: luaext.h $
** Compile-time extensions for Lua.
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of lua.h
*/
#ifndef luaext_h
#define luaext_h

#if defined(__cplusplus)

#define __lua_exception_only
#include "luaxx.hpp"
#undef luaxx_hpp
#undef __lua_exception_only

#if defined(LUAX_EXCEPTION_ENABLE)

#	define LUAI_THROW(L,c) \
    throw LUAX_EXCEPTION_THROW(L,c)

#	define LUAI_TRY(L,c,a) \
    try { a } \
    catch(...) { \
        if ((c)->status == 0) \
            throw; \
    }

#	define luai_jmpbuf \
    int  /* dummy variable */

#endif




#endif

#if 0
#if defined(EXPERY_LUA_MULTITHREADED) && (EXPERY_LUA_MULTITHREADED == 1)

#	if defined(__cplusplus)
#		include <mutex>
#	else
#		if defined(_POSIX_THREADS)
# 			warning "CODE UNTESTED"
#			include <pthread.h>
#		else
#			error "UNKNOWN THREAD TYPE"
#		endif
#	endif

struct global_UserState {
#	if defined(__cplusplus)
	std::mutex __mutex;
#	else
#		if defined(_POSIX_THREADS)
	pthread_mutex_t mutex;
#		endif
#	endif
};

#	define LUA_USER_GLOBAL_STATE struct global_UserState

#   define lua_lock(L)                     luaU_lock(L->l_G->userstate)
#   define lua_unlock(L)                   luaU_unlock(L->l_G->userstate)
#   define luai_threadyield(L)             {lua_unlock(L); lua_lock(L);}

#   define luai_userstateopen(L)           luaU_userstateopen(&(L->l_G->userstate))
#   define luai_userstateclose(L)          luaU_userstateclose(&(L->l_G->userstate))
#   define luai_userstatethread(L,L1)      ((void)L)
#   define luai_userstatefree(L,L1)        ((void)L)
#   define luai_userstateresume(L,n)       ((void)L)
#   define luai_userstateyield(L,n)        ((void)L)

static inline void luaU_lock(struct global_UserState *U) {
#if defined(__cplusplus)
	U->__mutex.lock();
#else
#		if defined(_POSIX_THREADS)
	pthread_mutex_lock(&U->mutex);
#		else
#			error "UNKNOWN THREAD TYPE"
#		endif
#endif
}

static inline void luaU_unlock(struct global_UserState *U) {
#if defined(__cplusplus)
	U->__mutex.unlock();
#else
#		if defined(_POSIX_THREADS)
	pthread_mutex_unlock(&U->mutex);
#		else
#			error "UNKNOWN THREAD TYPE"
#		endif
#endif
}

static inline void luaU_userstateopen(struct global_UserState **U) {
#if defined(__cplusplus)
	if (*U == NULL)
		*U = new global_UserState;
#else
	if (*U == NULL) {
		*U = cmalloc(sizeof(struct global_UserState));
		assert(*U ~= NULL);

#		if defined(_POSIX_THREADS)
		pthread_mutex_init(&(*U->mutex));
#		else
#			error "UNKNOWN THREAD TYPE"
#		endif
	}
#endif
}

static inline void luaU_userstateclose(struct global_UserState **U) {
#if defined(__cplusplus)
	if (*U != NULL) {
		delete (*U);
		*U = NULL;
	}
#else
	if (*U != NULL) {
#		if defined(_POSIX_THREADS)
		pthread_mutex_destroy(&(*U->mutex));
#		else
#			error "UNKNOWN THREAD TYPE"
#		endif
		*U = 0;
	}
#endif
}

#elif // defined(EXPERY_LUA_MULTITHREADED) && (EXPERY_LUA_MULTITHREADED == 1)

#   define lua_lock(L)                     ((void)L)
#   define lua_unlock(L)                   ((void)L)
#   define luai_threadyield(L)             {lua_unlock(L); lua_lock(L);}

#   define luai_userstateopen(L)           ((void)L)
#   define luai_userstateclose(L)          ((void)L)
#   define luai_userstatethread(L,L1)      ((void)L)
#   define luai_userstatefree(L,L1)        ((void)L)
#   define luai_userstateresume(L,n)       ((void)L)
#   define luai_userstateyield(L,n)        ((void)L)

#endif // EXPERY_LUA_MULTITHREADED

#endif

#endif
