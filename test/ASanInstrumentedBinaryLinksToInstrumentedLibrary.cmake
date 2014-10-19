# /test/ASanInstrumentedBinaryLinksToInstrumentedLibrary.cmake
# If SANITIZERS_USE_ASAN is set to ON and polysquare_sanitizers_bootstrap ()
# is called, then a target called executable_asan and library_asan should
# be created, and executable_asan should be linked to library_asan when
# executable is linked to library
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_sanitizers_bootstrap ()

set (LIBRARY_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/LibrarySource.c)
set (LIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})
set (LIBRARY_TARGET library)

set (EXECUTABLE_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/ExecutableSource.cpp)
set (EXECUTABLE_SOURCE_FILE_CONTENTS
     "extern \"C\" int function ()\;\n"
     "int main ()\n"
     "{\n"
     "    return function ()\;\n"
     "}\n")
file (WRITE ${EXECUTABLE_SOURCE_FILE} ${EXECUTABLE_SOURCE_FILE_CONTENTS})
set (EXECUTABLE_TARGET executable)

polysquare_add_library (${LIBRARY_TARGET} SHARED
                        SOURCES ${LIBRARY_SOURCE_FILE})

polysquare_add_executable (${EXECUTABLE_TARGET}
                           SOURCES ${EXECUTABLE_SOURCE_FILE}
                           LIBRARIES ${LIBRARY_TARGET})

assert_target_is_linked_to (${EXECUTABLE_TARGET}_asan
                            ${LIBRARY_TARGET}_asan)