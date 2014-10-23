# /test/NoUnityBuildOption.cmake
# Verifies that passing NO_UNITY_BUILD causes unity targets not to be generated.
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap ()

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)

set (SOURCE_FILE_CONTENTS
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (EXECUTABLE executable)

polysquare_add_executable (${EXECUTABLE}
                           SOURCES ${SOURCE_FILE}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                           NO_UNITY_BUILD)

assert_target_does_not_exist (${EXECUTABLE}_unity)