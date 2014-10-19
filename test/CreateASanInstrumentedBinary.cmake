# /test/CrateASanInstrumentedBinary.cmake
# If SANITIZERS_USE_ASAN is set to ON and polysquare_sanitizers_bootstrap ()
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
#
# See LICENCE.md for Copyright information

set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)

include (PolysquareCommon)
include (CMakeUnit)

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
                           SOURCES ${SOURCE_FILE})

assert_target_exists (${TARGET}_asan)