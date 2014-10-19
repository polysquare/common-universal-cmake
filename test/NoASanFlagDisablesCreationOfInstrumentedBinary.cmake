# /test/NoASanFlagDisablesCreationOfInstrumentedBinary
# If SANITIZERS_USE_ASAN is set to ON and polysquare_sanitizers_bootstrap ()
# is called, and polysquare_add_executable is called with NO_ASAN then a target
# called target_asan should not be created.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_sanitizers_bootstrap ()

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
set (TARGET target)

polysquare_add_executable (${TARGET}
                           SOURCES ${SOURCE_FILE}
                           NO_ASAN)

assert_target_does_not_exist (${TARGET}_asan)