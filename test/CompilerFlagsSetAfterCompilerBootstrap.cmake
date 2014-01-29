# /tests/CompilerFlagsSetAfterCompilerBootstrap.cmake
# Tests that we can add common-universal-cmake as a
# a subdirectory.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_compiler_bootstrap ()

assert_string_contains (${CMAKE_CXX_FLAGS} "-std=c++0x")
assert_string_contains (${CMAKE_CXX_FLAGS} "-fPIC")
assert_string_contains (${CMAKE_C_FLAGS} "-fPIC")
assert_string_contains (${CMAKE_CXX_FLAGS} "-Wall")
assert_string_contains (${CMAKE_C_FLAGS} "-Wall")
assert_string_contains (${CMAKE_CXX_FLAGS} "-Werror")
assert_string_contains (${CMAKE_C_FLAGS} "-Werror")
assert_string_contains (${CMAKE_CXX_FLAGS} "-Wextra")
assert_string_contains (${CMAKE_C_FLAGS} "-Wextra")
assert_string_contains (${CMAKE_CXX_FLAGS} "-Wno-unused-parameter")
assert_string_contains (${CMAKE_C_FLAGS} "-Wno-unused-parameter")
