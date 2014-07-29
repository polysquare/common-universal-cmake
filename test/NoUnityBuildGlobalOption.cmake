# /test/NoUnityBuildGlobalOption.cmake
# Verifies that setting POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS to FALSE causes unity
# targets not to be generated.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_compiler_bootstrap ()
polysquare_cotire_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)

set (SOURCE_FILE_CONTENTS
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (EXECUTABLE executable)

set (POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS OFF CACHE BOOL "" FORCE)

polysquare_add_executable (${EXECUTABLE}
                           SOURCES ${SOURCE_FILE}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

assert_target_does_not_exist (${EXECUTABLE}_unity)