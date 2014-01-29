# /tests/CoverageFlagsNotSetForClangAfterCoverageBootstrap.cmake
# Tests that coverage flags are not defined for non-gcc compilers even if
# we set ENABLE_COVERAGE in the cache
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (CMAKE_COMPILER_IS_GNUCXX FALSE CACHE BOOL "" FORCE)
set (CMAKE_COMPILER_IS_GNUCC FALSE CACHE BOOL "" FORCE)

set (ENABLE_COVERAGE TRUE CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_coverage_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

assert_string_does_not_contain (${CMAKE_CXX_FLAGS} "-ftest-coverage")
assert_string_does_not_contain (${CMAKE_C_FLAGS} "-ftest-coverage")
assert_string_does_not_contain (${CMAKE_CXX_FLAGS} "-fprofile-arcs")
assert_string_does_not_contain (${CMAKE_C_FLAGS} "-fprofile-arcs")
