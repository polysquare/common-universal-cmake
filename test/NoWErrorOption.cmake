# /tests/NoWErrorOption.cmake
# Tests upon setting the POLYSQARE_USE_STRICT_COMPILER cache value to FALSE
# that we do not use the -Werror flag
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (POLYSQUARE_USE_STRICT_COMPILER OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()

assert_string_does_not_contain (${CMAKE_CXX_FLAGS} "-Werror")
assert_string_does_not_contain (${CMAKE_C_FLAGS} "-Werror")
