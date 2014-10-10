# /tests/GenerateCompilationCommandsDatabaseAfterBootstrap.cmake
# Tests that CMAKE_EXPORT_COMPILE_COMMANDS is set after bootstrap
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()

assert_true (${CMAKE_EXPORT_COMPILE_COMMANDS})

# Also set up a target
set (SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
file (WRITE ${SOURCE}
	  "int main ()\n"
	  "{\n"
	  "    return 1;\n"
	  "}\n")

add_executable (target ${SOURCE})