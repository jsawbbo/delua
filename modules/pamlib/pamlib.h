/*
** DeLua Package Manager
** See Copyright Notice in version.h
*/
#ifndef pamlib_h
#define pamlib_h

#define PAM_VERSION_S "0.0"

#if defined(LUA_USE_WINDOWS)
#include <direct.h>
#include <io.h>
#include <windows.h>
#define pam_mkdir(dirname) _mkdir(dirname)
#define pam_chdir(dirname) _chdir(dirname)
#define pam_getcwd(buf, size) _getcwd(buf, size)
#define pam_isatty(stream) _isatty(_fileno(stream))
extern inline int pam_runasadmin() {
  BOOL fIsRunAsAdmin = FALSE;
  PSID pAdminSid = NULL;
  if (CreateWellKnownSid(WinBuiltinAdministratorsSid, NULL, &pAdminSid)) {
    if (!CheckTokenMembership(NULL, pAdminSid, &fIsRunAsAdmin)) {
      fIsRunAsAdmin = FALSE;
    }
    FreeSid(pAdminSid);
  }
  return fIsRunAsAdmin != FALSE;
}
#else
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#define pam_mkdir(dirname) mkdir(dirname, 0700)
#define pam_chdir(dirname) chdir(dirname)
#define pam_getcwd(buf, size) getcwd(buf, size)
#define pam_isatty(stream) isatty(fileno(stream))
extern inline int pam_runasadmin() { return getuid() == 0; }
#endif

#endif
