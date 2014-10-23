# /tests/AddTestTargetLinkedToMock.cmake
# Tests that the correct targets are set up when
# adding a Google Test based test
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_gmock_bootstrap ()

set (MOCK_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Mock.cpp)
set (MOCK_HEADER_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set (MOCK_HEADER_FILE ${MOCK_HEADER_DIRECTORY}/Mock.h)
set (MOCK_HEADER_FILE_CONTENTS
     "#ifndef _MOCK_HEADER\n"
     "#define _MOCK_HEADER\n"
     "#include <gmock/gmock.h>\n"
     "class Mock\n"
     "{\n"
     "    public:\n"
     "        Mock ()\;\n"
     "        ~Mock ()\;\n"
     "        MOCK_METHOD0 (mocked, void ())\;\n"
     "}\;\n"
     "#endif")
set (MOCK_SOURCE_FILE_CONTENTS
     "#include <gmock/gmock.h>\n"
     "#include \"Mock.h\"\n"
     "Mock::Mock ()\n"
     "{\n"
     "}\n"
     "Mock::~Mock ()\n"
     "{\n"
     "}\n")
file (WRITE ${MOCK_HEADER_FILE}
      ${MOCK_HEADER_FILE_CONTENTS})
file (WRITE ${MOCK_SOURCE_FILE}
      ${MOCK_SOURCE_FILE_CONTENTS})

set (TEST_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Test.cpp)
set (TEST_SOURCE_FILE_CONTENTS
     "#include <gtest/gtest.h>\n"
     "#include <gmock/gmock.h>\n"
     "#include <Mock.h>\n"
     "TEST(Sample, Test)\n"
     "{\n"
     "    Mock mock\;\n"
     "    EXPECT_CALL(mock, mocked ())\;\n"
     "    mock.mocked ()\;\n"
     "}\n")
file (WRITE ${TEST_SOURCE_FILE}
      ${TEST_SOURCE_FILE_CONTENTS})

polysquare_add_mock (mock
                     SOURCES ${MOCK_SOURCE_FILE}
                     INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                     EXPORT_HEADER_DIRECTORY ${MOCK_HEADER_DIRECTORY})

polysquare_add_test (unittest
                     SOURCES ${TEST_SOURCE_FILE}
                     MOCKS mock)

# We are disabling these for now as the version of
# CMake in Travis is too old and doesn't set
# INTERFACE_LINK_LIBRARIES or LINK_LIBRARIES
# when calling add_custom_target. The build step
# should cover us here anyways
# assert_target_is_linked_to (unittest "mock")
