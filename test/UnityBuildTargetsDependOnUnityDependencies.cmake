# /test/UnityBuildTargetsDependOnUnityDependencies.cmake
# Verifies the generated _unity target depends on the _unity version
# of other targets where those exists.
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_cotire_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

# Set up external project to build library
include (ExternalProject)

set (LIBRARY_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/LibrarySource.c)
set (LIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 1\;\n"
     "}\n")

set (LIBRARY library)

file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})

set (EXTLIBRARY_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ExternalLibrary)
set (EXTLIBRARY_BINARY_DIR ${EXTLIBRARY_PREFIX}/build)

polysquare_add_library (${LIBRARY} SHARED
	                    SOURCES
	                    ${LIBRARY_SOURCE_FILE})

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
set (LIBRARY_UNITY ${LIBRARY}_unity)

# The version of CMake in Travis-CI is still too old, so we still
# cannot use this check.
# assert_target_is_linked_to (${EXECUTABLE_UNITY} ${LIBRARY_UNITY})