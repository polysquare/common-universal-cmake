# /tests/CoverageFlagsNotSetForClangAfterCoverageBootstrap.cmake
# Tests that coverage flags are defined for gcc and g++ if
# we set ENABLE_COVERAGE in the cache
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (CMAKE_COMPILER_IS_GNUCXX TRUE CACHE BOOL "" FORCE)
set (CMAKE_COMPILER_IS_GNUCC TRUE CACHE BOOL "" FORCE)

set (ENABLE_COVERAGE TRUE CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_coverage_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

assert_string_contains (${CMAKE_CXX_FLAGS} "-ftest-coverage")
assert_string_contains (${CMAKE_C_FLAGS} "-ftest-coverage")
assert_string_contains (${CMAKE_CXX_FLAGS} "-fprofile-arcs")
assert_string_contains (${CMAKE_C_FLAGS} "-fprofile-arcs")
