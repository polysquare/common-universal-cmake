# /test/UnityBuildTargetsInheritTargetLinkLibraries.cmake
# Verifies the generated _unity target inherits all external target link
# libraries
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

# Set up external project to build library
include (ExternalProject)

set (EXTLIBRARY_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/ext_library)
set (EXTLIBRARY_SOURCE_FILE ${EXTLIBRARY_DIRECTORY}/LibrarySource.c)
set (EXTLIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 1\;\n"
     "}\n")

set (EXTLIBRARY ext_library)

set (EXTLIBRARY_CMAKELISTS_TXT ${EXTLIBRARY_DIRECTORY}/CMakeLists.txt)
set (EXTLIBRARY_CMAKELISTS_TXT_CONTENTS
     "project (ExtLibrary)\n"
     "cmake_minimum_required (VERSION 2.8)\n"
     "add_library (${EXTLIBRARY} STATIC ${EXTLIBRARY_SOURCE_FILE})\n"
     "set_target_properties (${EXTLIBRARY} PROPERTIES PREFIX \"\")")

file (MAKE_DIRECTORY ${EXTLIBRARY_DIRECTORY})
file (WRITE ${EXTLIBRARY_SOURCE_FILE} ${EXTLIBRARY_SOURCE_FILE_CONTENTS})
file (WRITE ${EXTLIBRARY_CMAKELISTS_TXT} ${EXTLIBRARY_CMAKELISTS_TXT_CONTENTS})

set (EXTLIBRARY_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ExternalLibrary)
set (EXTLIBRARY_BINARY_DIR ${EXTLIBRARY_PREFIX}/build)

ExternalProject_Add (ExternalLibrary
                     PREFIX ${EXTLIBRARY_PREFIX}
                     INSTALL_COMMAND ""
                     BINARY_DIR ${EXTLIBRARY_PREFIX}/build
                     URL ${EXTLIBRARY_DIRECTORY})

set (EXTLIBRARY_PATH ${EXTLIBRARY_BINARY_DIR}/${EXTLIBRARY}.a)

# Also create a rule to "generate" the library on disk by running
# the external project build process. This satisfies pre-build
# stat generators like Ninja.
add_custom_command (OUTPUT ${EXTLIBRARY_PATH}
                    DEPENDS ExternalLibrary)
add_custom_target (ensure_build_of_${EXTLIBRARY}
                   SOURCES ${EXTLIBRARY_PATH})

add_library (${EXTLIBRARY} STATIC IMPORTED GLOBAL)
set_target_properties (${EXTLIBRARY}
                       PROPERTIES IMPORTED_LOCATION ${EXTLIBRARY_PATH})

add_dependencies (${EXTLIBRARY} ExtLibrary)
add_dependencies (${EXTLIBRARY} ensure_build_of_${EXTLIBRARY})

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
                           LIBRARIES ${EXTLIBRARY}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

set (EXECUTABLE_UNITY ${EXECUTABLE}_unity)

# The version of CMake in Travis-CI is still too old, so we still
# cannot use this check.
# assert_target_is_linked_to (${EXECUTABLE_UNITY} ${EXTLIBRARY})