# /tests/VeraPPWithPolysquareProfileRunOnTargetWithRulesVerify.cmake
# Checks the build output to make sure that vera++ was run on our target
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "vera++")
assert_file_contains (${BUILD_OUTPUT} "Source.cpp --profile polysquare")
assert_file_contains (${BUILD_OUTPUT} "Header.h --profile polysquare")
assert_file_contains (${BUILD_OUTPUT} "--error")
