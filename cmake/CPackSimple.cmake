# Simplified packaging.
# ---------------------
#
# Tools and utitilities for setting up CPack in a simplified manner.
#
# Inspired by and some code copied from
#     https://github.com/neurosuite/libneurosuite/blob/master/cmake/modules/PackNeurosuite.cmake,
#     Copyright 2015 by Florian Franzen
# 
# See 
#     https://gitlab.kitware.com/cmake/community/wikis/doc/cpack/Packaging-With-CPack
# for more information.
cmake_minimum_required(VERSION 3.10)

# Debugging
set(__cpack_simple_report ON CACHE INTERNAL "Generate report for CPackSimple.")

# === Initialize defaults.
set(CPACK_GENERATOR "ZIP")
set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

# === Load macros
include(CPackSimple/Utils)
include(CPackSimple/Config)
include(CPackSimple/Components)
include(CPackSimple/Package)
