# /test/UnityBuildTargetsInheritTargetLinkLibraries.cmake
# Verifies the generated _unity target inherits all external target link
# libraries
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap ()

set (LIBRARY_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/LibrarySource.c)
set (LIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 1\;\n"
     "}\n")

set (LIBRARY library)

file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})

# Add library, but do not accelerate it
polysquare_add_library (${LIBRARY} STATIC
                        SOURCES ${LIBRARY_SOURCE_FILE}
                        NO_UNITY_BUILD
                        NO_PRECOMPILED_HEADERS)

# Set up main source file for unity build
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
                           LIBRARIES ${LIBRARY}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

set (EXECUTABLE_UNITY ${EXECUTABLE}_unity)

assert_target_is_linked_to (${EXECUTABLE_UNITY} ${LIBRARY})