#include "delua.hpp"

#if !defined(DELUA_LANGUAGE_CXX)
extern "C" {
#endif
//
#if !defined(DELUA_LANGUAGE_CXX)
}
#endif

const char *lua_Exception::what() const noexcept
{
  if (extra_) return extra_;

  switch (lua::status(status_)) {
  case lua::status::ok:
    return "ok";
  case lua::status::yield:
    return "thread yielded";
  case lua::status::error_run:
    return "runtime error";
  case lua::status::syntax:
    return "syntax error";
  case lua::status::memory:
    return "out of memory";
  case lua::status::error:
    return "error in garbage collector";
  default:
    return "unknown";
  }
}