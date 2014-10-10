# /tests/VeraPPWithPolysquareProfileRunOnTargetWithRulesVerify.cmake
# Checks the build output to make sure that vera++ was run on our target
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "cppcheck")
assert_file_contains (${BUILD_OUTPUT} "--enable=style")

# FIXME: This isn't great, but requires tricky regex-matching of individual
# lines in cmake-unit
assert_file_contains (${BUILD_OUTPUT} "Source.cpp")
assert_file_contains (${BUILD_OUTPUT} "--error-exitcode=1")
assert_file_contains (${BUILD_OUTPUT} "/var")
