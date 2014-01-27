# /tests/TestLibrariesAvailableAfterGoogleTestBootstrap.cmake
# Tests that the Google Test definitions, eg
#
# GTEST_LIBRARY
# GMOCK_LIBRARY
# GTEST_MAIN_LIBRARY
# GMOCK_MAIN_LIBRARY
#
# Are defined after calling polysquare_bootstrap_google_test
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

assert_variable_matches_regex (${GTEST_LIBRARY} "(^.*gtest.*$)")
assert_variable_matches_regex (${GTEST_MAIN_LIBRARY} "(^.*gtest_main.*$)")
assert_variable_matches_regex (${GMOCK_LIBRARY} "(^.*gmock.*$)")
assert_variable_matches_regex (${GMOCK_MAIN_LIBRARY} "(^.*gmock_main.*$)")
assert_variable_is_defined (CMAKE_THREAD_LIBS_INIT)