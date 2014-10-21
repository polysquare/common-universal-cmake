# /test/DependenciesLinkedToTarget.cmake
# Sets up a normal target depending on a custom target using the DEPENDS
# keyword.
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

# Set up a custom target to touch output
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