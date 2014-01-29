# /tests/VeraPPWithPolysquareProfileRunOnTargetWithRulesVerify.cmake
# Checks the build output to make sure that vera++ was run on our target
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

# We need to get the substring of the file starting from the point
# "Checking for unused functions" and ending at "polysquare_check_unused"
file (READ ${BUILD_OUTPUT} CONTENTS)
string (LENGTH ${CONTENTS} TOTAL_CONTENTS_LENGTH)
string (FIND ${CONTENTS} "Checking for unused functions" START_INDEX)
math (EXPR TRUNCATED_LENGTH "${TOTAL_CONTENTS_LENGTH} - ${START_INDEX}")
string (SUBSTRING ${CONTENTS} ${START_INDEX} ${TRUNCATED_LENGTH} START_POINT)
string (FIND ${START_POINT} "polysquare_check_unused" END_INDEX)
string (SUBSTRING ${START_POINT} 0 ${END_INDEX} UNUSED_FUNCTION_CHECK_CHUNK)

assert_string_contains (${UNUSED_FUNCTION_CHECK_CHUNK} "cppcheck")
assert_string_contains (${UNUSED_FUNCTION_CHECK_CHUNK} "--enable=unusedFunction")
assert_string_contains (${UNUSED_FUNCTION_CHECK_CHUNK} "-I/var")
assert_string_does_not_contain (${UNUSED_FUNCTION_CHECK_CHUNK} "-I/etc")
