# /tests/ClangTidyEnableChecksPassedVerify.cmake
# Checks the build output to make sure that clang-tidy was run on our
# target with the google-* checks.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (COMMAND
	 "^.*clang-tidy.*Source.cpp.*")
assert_file_has_line_matching (${BUILD_OUTPUT}
	                           "^.*clang-tidy.*-checks=google-.*$")