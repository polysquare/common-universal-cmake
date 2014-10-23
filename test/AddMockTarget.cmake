# /tests/AddMockTarget.cmake
# Tests that the correct targets are set up when
# adding a Google Mock based mock
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_gmock_bootstrap ()

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Header.h)
set (SOURCE_FILE_CONTENTS "")
set (HEADER_FILE_CONTENTS "")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

add_library (library SHARED
             ${SOURCE_FILE})

set (MOCK_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Mock.cpp)
set (MOCK_SOURCE_FILE_CONTENTS "")
file (WRITE ${MOCK_SOURCE_FILE}
      ${MOCK_SOURCE_FILE_CONTENTS})

polysquare_add_mock (mock
                     SOURCES ${MOCK_SOURCE_FILE}
                     INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                     LIBRARIES library)

# We are disabling these for now as the version of
# CMake in Travis is too old and doesn't set
# INTERFACE_LINK_LIBRARIES or LINK_LIBRARIES
# when calling add_custom_target. The build step
# should cover us here anyways
# assert_target_is_linked_to (matcher "library")
# assert_target_is_linked_to (matcher "gtest")
# assert_target_is_linked_to (matcher "gmock")
# assert_target_is_not_linked_to (matcher "gtest_main")
# assert_target_is_not_linked_to (matcher "gmock_main")
