/*
** $Id: luaext.h $
** Compile-time extensions for Lua.
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of lua.h
*/
#ifndef luaext_h
#define luaext_h

#if defined(__cplusplus)

/* load lua::except from luaxx.hpp */
#define __lua_exception_only
#include <luaxx.hpp>
#undef luaxx_hpp
#undef __lua_exception_only

/* threads */
#if defined(LUAX_THREAD_LOCKING)
#	if defined(__cplusplus)
#		include <mutex>
#	else
#		if LUAX_THREAD_PTHREADS == 1
			// FIXME check LUAX_THREAD_PTHREADS_HP?
#			include <pthread.h>
#		elif LUAX_THREAD_SPROC == 1
#			error "SPROC threads not (yet) supported."
#		elif LUAX_THREAD_WIN32 == 1
#			error "WIN32 threads not (yet) supported."
#		else
#			error "Configuration error: thread locking was enabled, but type is unknown."
#		endif
#	endif
#endif

/* =================================================================== */

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

#endif // LUAX_EXCEPTION_ENABLE

/* =================================================================== */

#if defined(LUAX_THREAD_LOCKING)
#	if defined(__cplusplus)
#		define 	__LUAX_MUTEX std::mutex mutex;
#	else
#		if LUAX_THREAD_PTHREADS == 1
#			define 	__LUAX_MUTEX pthread_mutex_t mutex;
#		elif LUAX_THREAD_SPROC == 1
#			error "SPROC threads not (yet) supported."
#		elif LUAX_THREAD_WIN32 == 1
#			error "WIN32 threads not (yet) supported."
#		else
#			error "Configuration error: thread locking was enabled, but type is unknown."
#		endif
#	endif
#endif

struct global_UserState {
	__LUAX_MUTEX;
};
#define LUA_USER_GLOBAL_STATE struct global_UserState

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
#	if defined(__cplusplus)
	U->mutex.lock();
#	else
#		if LUAX_THREAD_PTHREADS == 1
	pthread_mutex_lock(&U->mutex);
#		elif LUAX_THREAD_SPROC == 1
#		elif LUAX_THREAD_WIN32 == 1
#		endif
#	endif
}

static inline void luaU_unlock(struct global_UserState *U) {
#	if defined(__cplusplus)
	U->mutex.unlock();
#	else
#		if LUAX_THREAD_PTHREADS == 1
	pthread_mutex_unlock(&U->mutex);
#		elif LUAX_THREAD_SPROC == 1
#		elif LUAX_THREAD_WIN32 == 1
#		endif
#	endif
}

static inline void luaU_userstateopen(struct global_UserState **U) {
#	if defined(__cplusplus)
	if (*U == NULL)
		*U = new global_UserState;
#	else
	if (*U == NULL) {
		*U = ::cmalloc(sizeof(struct global_UserState));
		assert(*U ~= NULL);

#		if LUAX_THREAD_PTHREADS == 1
	pthread_mutex_init(&(*U->mutex));
#		elif LUAX_THREAD_SPROC == 1
#		elif LUAX_THREAD_WIN32 == 1
#		else
#			error "Configuration error: thread locking was enabled, but type is unknown."
#		endif
#	endif
}

static inline void luaU_userstateclose(struct global_UserState **U) {
	if (*U != NULL) {
#	if defined(__cplusplus)
		delete (*U);
#	else
#		if LUAX_THREAD_PTHREADS == 1
		pthread_mutex_destroy(&(*U->mutex));
		::free(*U)
#		elif LUAX_THREAD_SPROC == 1
#		elif LUAX_THREAD_WIN32 == 1
#		endif
#	endif
		*U = NULL;
	}
}

#endif // LUAX_THREAD_LOCKING

/* =================================================================== */

#endif
