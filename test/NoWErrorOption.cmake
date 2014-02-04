# /tests/NoWErrorOption.cmake
# Tests upon setting the POLYSQARE_USE_STRICT_COMPILER cache value to FALSE
# that we do not use the -Werror flag
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (POLYSQUARE_USE_STRICT_COMPILER OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()

assert_string_does_not_contain (${CMAKE_CXX_FLAGS} "-Werror")
assert_string_does_not_contain (${CMAKE_C_FLAGS} "-Werror")
