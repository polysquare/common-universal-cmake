# /tests/ClangTidyDisableChecksPassedVerify.cmake
# Checks the build output to make sure that clang-tidy was run on our
# target withouyt the misc-* checks.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (COMMAND
	 "^.*clang-tidy.*Source.cpp.*")
assert_file_has_line_matching (${BUILD_OUTPUT}
	                           "^.*clang-tidy.*-checks=.*-misc-.*$")