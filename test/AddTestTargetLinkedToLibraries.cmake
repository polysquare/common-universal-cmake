# /tests/AddTestTargetLinkedToLibraries.cmake
# Tests that the correct targets are set up when
# adding a Google Test based test
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (CMAKE_MODULE_PATH
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/gmock-cmake
     ${CMAKE_MODULE_PATH})

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Header.h)
set (SOURCE_FILE_CONTENTS
     "#include \"Header.h\"\n"
     "bool function()\n"
     "{\n"
     "    return true\;\n"
     "}\n")
set (HEADER_FILE_CONTENTS
     "#ifndef _HEADER_FILE\n"
     "#define _HEADER_FILE\n"
     "bool function()\;\n"
     "#endif\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

set (TEST_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Test.cpp)
set (TEST_SOURCE_FILE_CONTENTS
     "#include <gtest/gtest.h>\n"
     "#include <gmock/gmock.h>\n"
     "#include <Header.h>\n"
     "TEST(Sample, Test)\n"
     "{\n"
     "    EXPECT_TRUE(function())\;\n"
     "}\n")
file (WRITE ${TEST_SOURCE_FILE}
      ${TEST_SOURCE_FILE_CONTENTS})

add_library (library SHARED
             ${SOURCE_FILE})

polysquare_add_test (unittest
                     SOURCES ${TEST_SOURCE_FILE}
                     INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                     LIBRARIES library)

# We are disabling these for now as the version of
# CMake in Travis is too old and doesn't set
# INTERFACE_LINK_LIBRARIES or LINK_LIBRARIES
# when calling add_custom_target. The build step
# should cover us here anyways
# assert_target_is_linked_to (unittest "library")
