include_guard()

set(PACKAGE_VERSION "@DeLua_VERSION_MAJOR@.@DeLua_VERSION_MINOR@.@DeLua_VERSION_PATCH@.@DeLua_VERSION_TWEAK@")

set(PACKAGE_VERSION_MAJOR @DeLua_VERSION_MAJOR@)
set(PACKAGE_VERSION_MINOR @DeLua_VERSION_MINOR@)
set(PACKAGE_VERSION_PATCH @DeLua_VERSION_PATCH@)

if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
    math(EXPR PACKAGE_VERSION_NEXT_MINOR "${PACKAGE_VERSION_MINOR} + 1") 
    set(PACKAGE_NEXT_VERSION ${PACKAGE_VERSION_MAJOR}.${PACKAGE_VERSION_NEXT_MINOR})
    if (PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_NEXT_VERSION)
        set(PACKAGE_VERSION_COMPATIBLE FALSE)
    else()
        set(PACKAGE_VERSION_COMPATIBLE TRUE)
    endif()
endif()

# if the installed or the using project don't have CMAKE_SIZEOF_VOID_P set, ignore it:
if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "" OR "8" STREQUAL "")
  return()
endif()

# check that the installed version has the same 32/64bit-ness as the one which is currently searching:
if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "8")
    math(EXPR installedBits "8 * 8")
    set(PACKAGE_VERSION "${PACKAGE_VERSION} (${installedBits}bit)")
    set(PACKAGE_VERSION_UNSUITABLE TRUE)
endif()

message(STATUS "Found DeLua: version ${PACKAGE_VERSION}")
