# /tests/GeneratedSourcesNotAddedToSources.cmake
#
# Check that when adding a target with the GENERATED_SOURCES
# property that this file is not added to the target's SOURCES
# but instead added to each source file's OBJECT_DEPENDS

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "bool function()\n"
     "{\n"
     "    return true\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (GENERATED_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Generated.cpp)
add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE}
                    COMMAND touch ${GENERATED_SOURCE_FILE})

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE}
                        GENERATED_SOURCES ${GENERATED_SOURCE_FILE})

assert_does_not_have_property_containing_value (TARGET library
                                                SOURCES
                                                STRING EQUAL
                                                ${GENERATED_SOURCE_FILE})

assert_has_property_containing_value (SOURCE ${SOURCE_FILE}
                                      OBJECT_DEPENDS
                                      STRING EQUAL
                                      ${GENERATED_SOURCE_FILE})
