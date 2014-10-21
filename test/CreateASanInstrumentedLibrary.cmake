# /test/CrateASanInstrumentedLibrary.cmake
# If SANITIZERS_USE_ASAN is set to ON and polysquare_sanitizers_bootstrap ()
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_sanitizers_bootstrap ()

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
set (TARGET target)

polysquare_add_library (${TARGET} SHARED
                        SOURCES ${SOURCE_FILE})

assert_target_exists (${TARGET}_asan)
assert_has_property_with_value (TARGET ${TARGET}_asan
                                TYPE STRING EQUAL "SHARED_LIBRARY")