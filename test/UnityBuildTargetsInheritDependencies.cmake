# /test/UnityBuildTargetsInheritDependencies.cmake
# Verifies the generated _unity target inherits all non-library
# dependencies
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_compiler_bootstrap ()
polysquare_cotire_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

# Set up a custom target to write 'o' every single time it is run
find_program (CMAKE_EXECUTABLE cmake)
set (CUSTOM_COMMAND_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/custom_command_output)
file (REMOVE ${CUSTOM_COMMAND_OUTPUT})
add_custom_command (OUTPUT ${CUSTOM_COMMAND_OUTPUT}
                    COMMAND ${CMAKE_EXECUTABLE} -E touch ${CUSTOM_COMMAND_OUTPUT})

set (CUSTOM_TARGET_NAME custom_target)
add_custom_target (${CUSTOM_TARGET_NAME}
                   SOURCES ${CUSTOM_COMMAND_OUTPUT})

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
                           DEPENDS ${CUSTOM_TARGET_NAME})