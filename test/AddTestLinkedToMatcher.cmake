# /tests/AddTestTargetLinkedToMatchers.cmake
# Tests that the correct targets are set up when
# adding a Google Test based test
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (MATCHER_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Matcher.cpp)
set (MATCHER_HEADER_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set (MATCHER_HEADER_FILE ${MATCHER_HEADER_DIRECTORY}/Matcher.h)
set (MATCHER_HEADER_FILE_CONTENTS
     "#ifndef _MATCHER_HEADER\n"
     "#define _MATCHER_HEADER\n"
     "#include <gmock/gmock.h>\n"
     "class CustomMatcher :\n"
     "    public ::testing::MatcherInterface<bool>\n"
     "{\n"
     "    public:\n"
     "        typedef ::testing::MatchResultListener MRL\;\n"
     "        bool MatchAndExplain (bool t, MRL *listener) const\;\n"
     "        void DescribeTo (::std::ostream *os)const \;\n"
     "}\;\n"
     "::testing::Matcher <bool> IsCustom ()\;\n"
     "#endif")
set (MATCHER_SOURCE_FILE_CONTENTS
     "#include <gmock/gmock.h>\n"
     "#include \"Matcher.h\"\n"
     "using ::testing::MatcherInterface\;\n"
     "using ::testing::Matcher\;\n"
     "using ::testing::MakeMatcher\;\n"
     "using ::testing::MatchResultListener\;\n"
     "bool CustomMatcher::MatchAndExplain (bool t, MRL *listener) const\n"
     "{\n"
     "    return true\;\n"
     "}\n"
     "void CustomMatcher::DescribeTo (::std::ostream *os) const\n"
     "{\n"
     "}\n"
     "Matcher <bool> IsCustom ()\n"
     "{\n"
     "    return MakeMatcher (new CustomMatcher ())\;\n"
     "}\n")
file (WRITE ${MATCHER_HEADER_FILE}
      ${MATCHER_HEADER_FILE_CONTENTS})
file (WRITE ${MATCHER_SOURCE_FILE}
      ${MATCHER_SOURCE_FILE_CONTENTS})

set (TEST_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Test.cpp)
set (TEST_SOURCE_FILE_CONTENTS
     "#include <gtest/gtest.h>\n"
     "#include <gmock/gmock.h>\n"
     "#include <Matcher.h>\n"
     "TEST(Sample, Test)\n"
     "{\n"
     "    EXPECT_THAT(true, IsCustom ())\;\n"
     "}\n")
file (WRITE ${TEST_SOURCE_FILE}
      ${TEST_SOURCE_FILE_CONTENTS})

polysquare_add_matcher (matcher
                        SOURCES ${MATCHER_SOURCE_FILE}
                        INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                        EXPORT_HEADER_DIRECTORY ${MATCHER_HEADER_DIRECTORY})

polysquare_add_test (unittest
                     SOURCES ${TEST_SOURCE_FILE}
                     MATCHERS matcher)

# We are disabling these for now as the version of
# CMake in Travis is too old and doesn't set
# INTERFACE_LINK_LIBRARIES or LINK_LIBRARIES
# when calling add_custom_target. The build step
# should cover us here anyways
# assert_target_is_linked_to (unittest "matcher")
