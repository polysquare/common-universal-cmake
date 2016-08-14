# /CMakeLists.txt
#
# Main entry point for PolysquareCommon tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")

set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

set (_CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}")

include ("cmake/cmake-module-common/Common" OPTIONAL)
include (PolysquareCommon)

if ("${_CMAKE_UNIT_PHASE}" STREQUAL "PRECONFIGURE") # NOLINT:access/private_var

    # We build a copy of Google Test locally and then specify its location in
    # the cache. This allows the tests to immediately use that copy as opposed
    # to having to download it all the time.
    include (PolysquareCommon)

    set (GTEST_FORCE_FIND_STATIC ON)

    conan_basic_setup ()
    psq_compiler_bootstrap ()
    psq_gmock_bootstrap ()

    set (GMOCK_FORWARD_VARS GTEST_INCLUDE_DIR
                            GTEST_LIBRARY_LOCATION
                            GTEST_MAIN_LIBRARY_LOCATION
                            GMOCK_INCLUDE_DIR
                            GMOCK_LIBRARY_LOCATION
                            GMOCK_MAIN_LIBRARY_LOCATION)

    # Check for the presence of Vera++, CPPCheck, include-what-you-use
    # and clang-tidy
    psq_rules_bootstrap ()

    # Check for the presence of AddressSanitizer, MemorySanitizer,
    # ThreadSanitizer, UndefinedBehaviourSanitizer. If any of these get set to
    # OFF, the sanitizer is not available.
    set (SANITIZERS_USE_ASAN ON CACHE FORCE "")
    set (SANITIZERS_USE_MSAN ON CACHE FORCE "")
    set (SANITIZERS_USE_TSAN ON CACHE FORCE "")
    set (SANITIZERS_USE_UBSAN ON CACHE FORCE "")

    psq_sanitizers_bootstrap ()

else ()

    # Leave all flags here as ON, since we only need them to be ON
    # or OFF during the preconfigure phase.
    set (SANITIZERS_USE_ASAN ON)
    set (SANITIZERS_USE_MSAN ON)
    set (SANITIZERS_USE_TSAN ON)
    set (SANITIZERS_USE_UBSAN ON)
    set (SANITIZERS_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS ON)
    set (SANITIZERS_HAVE_UBSAN_NO_SANITIZE_RECOVER ON)
    set (SANITIZERS_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW ON)
    set (POLYSQUARE_HAVE_CPPCHECK ON)
    set (POLYSQUARE_HAVE_IWYU ON)
    set (POLYSQUARE_HAVE_VERAPP ON)
    set (POLYSQUARE_HAVE_CLANG_TIDY ON)

endif ()

# Tests that the correct targets are set up when
# adding a Google Test based test
function (psq_test_add_matcher_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_gmock_bootstrap ()
        set (MATCHER_SOURCE "Matcher.cpp")
        cmake_unit_create_simple_library (library SHARED)
        cmake_unit_create_source_file_before_build (NAME
                                                    "${MATCHER_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        psq_add_matcher (matcher
                         SOURCES "${MATCHER_SOURCE}"
                         INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                         LIBRARIES library)

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that the correct targets are set up when
# adding a Google Mock based mock
function (psq_test_add_mock_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_gmock_bootstrap ()
        set (MOCK_SOURCE "Mock.cpp")
        cmake_unit_create_simple_library (library SHARED)
        cmake_unit_create_source_file_before_build (NAME
                                                    "${MOCK_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        psq_add_mock (mock
                      SOURCES "${MOCK_SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      LIBRARIES library)

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Adds a new target with arbitrary sources and runs rule checkers on them.
# Also forces a particular language for the source, to ensure that the rule
# checkers know what it is.
function (psq_test_add_sources_scan_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        psq_gmock_bootstrap ()
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME "Header.h"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        psq_add_checked_sources (headers_check
                                 SOURCES "${SOURCE_DIR}/Source.cpp"
                                         "${SOURCE_DIR}/Header.h"
                                 INTERNAL_INCLUDE_DIRS "${BINARY_DIR}"
                                 FORCE_LANGUAGE CXX
                                 NO_UNUSED_CHECK)
        cmake_unit_assert_that (headers_check target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that the test was correctly added and
# built as a result of building it
function (psq_verify_g_test BINARY_DIR)

    psq_import_cfg_int_dir_helper ("${BINARY_DIR}")
    set (TEST_BINARY
         "${BINARY_DIR}/${CMAKE_CFG_INTDIR}/unittest")
    cmake_unit_assert_that ("${TEST_BINARY}" executes_with_success)


endfunction ()

# Tests that the correct targets are set up when
# adding a Google Test based test
function (psq_test_add_test_linked_to_main_library)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_gmock_bootstrap ()
        set (MAINLIB_SOURCE "MainLibrary.cpp")
        set (MAINLIB_SOURCE_CONTENTS
             "#include <gtest/gtest.h>\n"
             "int main (int argc, char **argv)\n"
             "{\n"
             "    ::testing::InitGoogleTest (&argc, argv)@SEMICOLON@\n"
             "    return RUN_ALL_TESTS ()@SEMICOLON@\n"
             "}\n")
        set (TEST_SOURCE "Test.cpp")
        set (TEST_SOURCE_CONTENTS
             "#include <gtest/gtest.h>\n"
             "#include <gmock/gmock.h>\n"
             "TEST(Sample, Test)\n"
             "{\n"
             "    EXPECT_TRUE(true)@SEMICOLON@\n"
             "}\n")

        cmake_unit_create_source_file_before_build (NAME
                                                    "${MAINLIB_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${MAINLIB_SOURCE_CONTENTS})
        cmake_unit_create_source_file_before_build (NAME "${TEST_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${TEST_SOURCE_CONTENTS})

        psq_add_test_main (test_main SOURCES "${MAINLIB_SOURCE}")
        psq_add_test (unittest SOURCES "${TEST_SOURCE}"
                      MAIN_LIBRARY test_main)
        cmake_unit_assert_that (unittest is_linked_to test_main)

    endfunction ()

    function (psq_verify)

        psq_verify_g_test ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               PRECONFIGURE FORWARD_CACHE_VARIABLES
                                            ${GMOCK_FORWARD_VARS}
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that the correct targets are set up when
# adding a Google Test based test
function (psq_test_add_test_linked_to_matcher)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_gmock_bootstrap ()
        set (MATCHER_SOURCE "Matcher.cpp")
        set (MATCHER_HEADER "Matcher.h")
        set (MATCHER_HEADER_CONTENTS
             "#ifndef _MATCHER_HEADER\n"
             "#define _MATCHER_HEADER\n"
             "#include <gmock/gmock.h>\n"
             "class CustomMatcher :\n"
             "    public ::testing::MatcherInterface<bool>\n"
             "{\n"
             "    public:\n"
             "        typedef ::testing::MatchResultListener MRL@SEMICOLON@\n"
             "        bool MatchAndExplain (bool t,\n"
             "                              MRL *listener) const@SEMICOLON@\n"
             "        void DescribeTo (::std::ostream *os) const@SEMICOLON@\n"
             "}@SEMICOLON@\n"
             "::testing::Matcher <bool> IsCustom ()@SEMICOLON@\n"
             "#endif")
        set (MATCHER_SOURCE_CONTENTS
             "#include <gmock/gmock.h>\n"
             "#include \"Matcher.h\"\n"
             "using ::testing::MatcherInterface@SEMICOLON@\n"
             "using ::testing::Matcher@SEMICOLON@\n"
             "using ::testing::MakeMatcher@SEMICOLON@\n"
             "using ::testing::MatchResultListener@SEMICOLON@\n"
             "bool CustomMatcher::MatchAndExplain (bool t,\n"
             "                                     MRL *listener) const\n"
             "{\n"
             "    return true@SEMICOLON@\n"
             "}\n"
             "void CustomMatcher::DescribeTo (::std::ostream *os) const\n"
             "{\n"
             "}\n"
             "Matcher <bool> IsCustom ()\n"
             "{\n"
             "    return MakeMatcher (new CustomMatcher ())@SEMICOLON@\n"
             "}\n")
        set (TEST_SOURCE "Test.cpp")
        set (TEST_SOURCE_CONTENTS "#include <gtest/gtest.h>\n"
             "#include <gmock/gmock.h>\n"
             "#include <Matcher.h>\n"
             "TEST(Sample, Test)\n"
             "{\n"
             "    EXPECT_THAT(true, IsCustom ())@SEMICOLON@\n"
             "}\n")

        cmake_unit_create_source_file_before_build (NAME "${MATCHER_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${MATCHER_SOURCE_CONTENTS})
        cmake_unit_create_source_file_before_build (NAME "${MATCHER_HEADER}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${MATCHER_HEADER_CONTENTS})
        cmake_unit_create_source_file_before_build (NAME "${TEST_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${TEST_SOURCE_CONTENTS})

        psq_add_matcher (matcher
                         SOURCES "${MATCHER_SOURCE}"
                                 "${MATCHER_HEADER}"
                         INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                         EXPORT_HEADER_DIRECTORY "${SOURCE_DIR}")
        psq_add_test (unittest
                      SOURCES "${TEST_SOURCE}"
                      MATCHERS matcher)
        cmake_unit_assert_that (unittest is_linked_to matcher)

    endfunction ()

    function (psq_verify)

        psq_verify_g_test ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               PRECONFIGURE FORWARD_CACHE_VARIABLES
                                            ${GMOCK_FORWARD_VARS}
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that the correct targets are set up when
# adding a Google Test based test
function (psq_test_add_test_linked_to_mock)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_gmock_bootstrap ()
        set (MOCK_SOURCE "Mock.cpp")
        set (MOCK_HEADER "Mock.h")
        set (MOCK_HEADER_CONTENTS
             "#ifndef _MOCK_HEADER\n"
             "#define _MOCK_HEADER\n"
             "#include <gmock/gmock.h>\n"
             "class Mock\n"
             "{\n"
             "    public:\n"
             "        Mock ()@SEMICOLON@\n"
             "        ~Mock ()@SEMICOLON@\n"
             "        MOCK_METHOD0 (mocked, void ())@SEMICOLON@\n"
             "}@SEMICOLON@\n"
             "#endif")
        set (MOCK_SOURCE_CONTENTS
             "#include <gmock/gmock.h>\n"
             "#include \"Mock.h\"\n"
             "Mock::Mock ()\n"
             "{\n"
             "}\n"
             "Mock::~Mock ()\n"
             "{\n"
             "}\n")
        set (TEST_SOURCE "Test.cpp")
        set (TEST_SOURCE_CONTENTS
             "#include <gtest/gtest.h>\n"
             "#include <gmock/gmock.h>\n"
             "TEST(Sample, Test)\n"
             "{\n"
             "    EXPECT_TRUE(true)@SEMICOLON@\n"
             "}\n")

        cmake_unit_create_source_file_before_build (NAME "${MOCK_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${MOCK_SOURCE_CONTENTS})
        cmake_unit_create_source_file_before_build (NAME "${MOCK_HEADER}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${MOCK_HEADER_CONTENTS})
        cmake_unit_create_source_file_before_build (NAME "${TEST_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${TEST_SOURCE_CONTENTS})

        psq_add_mock (mock
                      SOURCES "${MOCK_SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      EXPORT_HEADER_DIRECTORY "${SOURCE_DIR}")
        psq_add_test (unittest SOURCES "${TEST_SOURCE}" MOCKS mock)
        cmake_unit_assert_that (unittest is_linked_to mock)

    endfunction ()

    function (psq_verify)

        psq_verify_g_test ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               PRECONFIGURE FORWARD_CACHE_VARIABLES
                                            ${GMOCK_FORWARD_VARS}
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that the correct targets are set up when
# adding a Google Test based test
function (psq_test_add_test_target_linked_to_libraries)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_gmock_bootstrap ()

        set (TEST_SOURCE "Test.cpp")
        set (TEST_SOURCE_CONTENTS
             "#include <gtest/gtest.h>\n"
             "#include <gmock/gmock.h>\n"
             "TEST(Sample, Test)\n"
             "{\n"
             "}\n")
        cmake_unit_create_simple_library (library SHARED
                                          FUNCTIONS func)
        cmake_unit_create_source_file_before_build (NAME "${TEST_SOURCE}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}"
                                                    PREPEND_CONTENTS
                                                    ${TEST_SOURCE_CONTENTS})
        psq_add_test (unittest
                      SOURCES "${TEST_SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      LIBRARIES library)
        cmake_unit_assert_that (unittest is_linked_to library)

    endfunction ()

    function (psq_verify)

        psq_verify_g_test ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               PRECONFIGURE FORWARD_CACHE_VARIABLES
                                            ${GMOCK_FORWARD_VARS}
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

macro (_psq_define_options_for_instrumented_binary PSQ_FWD CREATE_SRC_FWD)

    set (OPTION_ARGS ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS}
         FUNCTIONS_EXPORT_TARGET)
    set (MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS}
         INCLUDES
         FUNCTIONS
         PREPEND_CONTENTS
         INCLUDE_DIRECTORIES)

    cmake_parse_arguments (PSQ_CREATE_INSTRUMENTED_BINARY
                           "${OPTION_ARGS}"
                           "${SINGLEVAR_ARGS}"
                           "${MULTIVAR_ARGS}"
                           ${ARGN})

    # Always prepend a copyright notice to PREPEND_CONTENTS, to keep
    # vera++ happy.
    set (PSQ_CREATE_INSTRUMENTED_BINARY_PREPEND_CONTENTS
         "/* Copyright */\n"
         ${PSQ_CREATE_INSTRUMENTED_BINARY_PREPEND_CONTENTS})

    cmake_forward_arguments (PSQ_CREATE_INSTRUMENTED_BINARY
                             ${PSQ_FWD}
                             OPTION_ARGS
                             "${PSQ_ALL_BINARY_OPTION_ARGS}"
                             SINGLEVAR_ARGS
                             "${PSQ_ALL_BINARY_SINGLEVAR_ARGS}"
                             MULTIVAR_ARGS
                             "${PSQ_ALL_BINARY_MULTIVAR_ARGS}")
    cmake_forward_arguments (PSQ_CREATE_INSTRUMENTED_BINARY
                             ${CREATE_SRC_FWD}
                             SINGLEVAR_ARGS FUNCTIONS_EXPORT_TARGET
                             MULTIVAR_ARGS INCLUDES
                                           DEFINES
                                           FUNCTIONS
                                           PREPEND_CONTENTS
                                           INCLUDE_DIRECTORIES)

endmacro ()

function (_psq_create_simple_instrumented_library NAME TYPE)

    _psq_define_options_for_instrumented_binary (PSQ_CREATE_LIBRARY_FWD
                                                 CREATE_SOURCE_FWD
                                                 ${ARGN})
    cmake_unit_create_source_file_before_build (NAME "Header.h"
                                                ${CREATE_SOURCE_FWD}
                                                GENERATING_FILE
                                                "${_CURRENT_LIST_FILE}"
                                                FUNCTIONS_EXPORT_TARGET
                                                ${NAME})
    cmake_unit_create_source_file_before_build (NAME "Library.cpp"
                                                ${CREATE_SOURCE_FWD}
                                                INCLUDES "Header.h"
                                                INCLUDE_DIRECTORIES
                                                "${CMAKE_CURRENT_SOURCE_DIR}"
                                                GENERATING_FILE
                                                "${_CURRENT_LIST_FILE}"
                                                FUNCTIONS_EXPORT_TARGET
                                                ${NAME})

    psq_add_library (${NAME} ${TYPE}
                     SOURCES "Library.cpp"
                             "Header.h"
                     ${PSQ_CREATE_LIBRARY_FWD})

endfunction ()

function (_psq_create_simple_instrumented_executable NAME)

    _psq_define_options_for_instrumented_binary (PSQ_CREATE_EXECUTABLE_FWD
                                                 CREATE_SOURCE_FWD
                                                 ${ARGN})
    cmake_unit_create_source_file_before_build (NAME "Executable.cpp"
                                                ${CREATE_SOURCE_FWD}
                                                GENERATING_FILE
                                                "${_CURRENT_LIST_FILE}")
    psq_add_executable (${NAME} ${TYPE}
                        SOURCES "Executable.cpp"
                        ${PSQ_CREATE_EXECUTABLE_FWD})

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called executable_asan and library_asan should
# be created, and executable_asan should be linked to library_asan when
# executable is linked to library
function (psq_test_asan_instrumented_binary_links_to_instrumented_library)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (LIBRARY_TARGET library)
        set (EXECUTABLE_TARGET executable)
        _psq_create_simple_instrumented_library (${LIBRARY_TARGET} SHARED
                                                 FUNCTIONS func)
        _psq_create_simple_instrumented_executable (${EXECUTABLE_TARGET}
                                                    FUNCTIONS main
                                                    LIBRARIES
                                                    ${LIBRARY_TARGET})

        cmake_unit_assert_that (${EXECUTABLE_TARGET}_asan is_linked_to
                                ${LIBRARY_TARGET}_asan)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (LINKER_LINE "^.*executable_asan.*library_asan.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${LINKER_LINE})

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Specifies a list of sources to be checked as part of a group along with
# some generated sources and the CHECK_GENERATED option.
function (psq_test_checks_can_be_run_on_generated_files)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_generate_source_file_during_build (GEN_TARGET
                                                      NAME "Generated.cpp")

        set (SOURCE_GROUP source_group)
        set (SOURCES "${SOURCE_DIR}/Source.cpp"
                     "${BINARY_DIR}/Generated.cpp")
        psq_add_checked_sources (${SOURCE_GROUP}
                                 SOURCES ${SOURCES}
                                 CHECK_GENERATED)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (VERAPP_ON_GENERATED_FILE_REGEX "^.*vera\\+\\+.*Generated\\.cpp.*$")
        set (CPPCHECK_ON_GENERATED_FILE_REGEX "^.*cppcheck.*Generated\\.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${VERAPP_ON_GENERATED_FILE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CPPCHECK_ON_GENERATED_FILE_REGEX})

    endfunction ()

    if (POLYSQUARE_USE_VERAPP AND POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Specifies a list of sources to be checked as part of a group.
function (psq_test_check_sources_re_run_if_sources_updated)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_generate_source_file_during_build (GEN_TARGET
                                                      NAME "Generated.cpp")
        set (SOURCE "${SOURCE_DIR}/Source.cpp")
        set (GENERATED_SOURCE
             "${BINARY_DIR}/Generated.cpp")
        set (SOURCE_GROUP source_group)
        set (STAMPFILE "${BINARY_DIR}/${SOURCE_GROUP}.stamp")
        file (WRITE ${STAMPFILE} "")
        set (SOURCES "${SOURCE}" "${GENERATED_SOURCE}")
        psq_add_checked_sources (${SOURCE_GROUP}
                                 SOURCES ${SOURCES}
                                 CHECK_GENERATED)
        add_dependencies (${SOURCE_GROUP} "${GENERATED_SOURCE}")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (VERAPP_ON_SOURCE_REGEX "^.*vera\\+\\+.*Source\\.cpp.*$")
        set (VERAPP_ON_GENERATED_FILE_REGEX "^.*vera\\+\\+.*Generated\\.cpp.*$")
        set (CPPCHECK_ON_SOURCE_REGEX "^.*cppcheck.*Source\\.cpp.*$")
        set (CPPCHECK_ON_SOURCE_REGEX "^.*cppcheck.*Source\\.cpp.*$")
        set (CPPCHECK_ON_GENERATED_FILE_REGEX "^.*cppcheck.*Generated\\.cpp.*$")
        set (CLANG_TIDY_ON_SOURCE_REGEX "^.*clang-tidy.*Source\\.cpp.*$")
        set (CLANG_TIDY_ON_GENERATED_FILE_REGEX
             "^.*clang-tidy.*Generated\\.cpp$")
        set (IWYU_ON_SOURCE_REGEX
             "^.*Source\\.cpp.*include-what-you-use.*$")
        set (IWYU_ON_GENERATED_FILE_REGEX
             "^.*Generated\\.cpp.*include-what-you-use.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${VERAPP_ON_SOURCE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${VERAPP_ON_GENERATED_FILE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CPPCHECK_ON_SOURCE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CPPCHECK_ON_GENERATED_FILE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_ON_SOURCE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_ON_GENERATED_FILE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_ON_SOURCE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_ON_GENERATED_FILE_REGEX})


    endfunction ()

    if (POLYSQUARE_USE_VERAPP AND
        POLYSQUARE_HAVE_CPPCHECK AND
        POLYSQUARE_HAVE_CLANG_TIDY)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Adds some custom definitions to our library. The definitions should be
# applied to all of its sources, plus any of its checks.
function (psq_test_check_sources_run_with_correct_defines)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        set (CONTENTS
             "bool function() {\n"
             "    return CUSTOM_DEFINITION@SEMICOLON@\n"
             "}\n")
        _psq_create_simple_instrumented_library (lib SHARED
                                                 PREPEND_CONTENTS "${CONTENTS}"
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 DEFINES CUSTOM_DEFINITION=true
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        if (CMAKE_GENERATOR STREQUAL "Ninja" OR
            CMAKE_GENERATOR STREQUAL "Unix Makefiles")
            set (COMPILE_COMMANDS "${BINARY_DIR}/compile_commands.json")

        else ()
            set (COMPILE_COMMANDS
                 "${BINARY_DIR}/lib_compile_commands/compile_commands.json")

        endif ()

        string (REPLACE "+" "." ESC_CXX_COMP "${CMAKE_CXX_COMPILER}")
        set (COMPILE_REGEX
             "^.*${ESC_CXX_COMP}.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
        set (CPPCHECK_REGEX
             "^.*cppcheck.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
        set (CLANG_TIDY_REGEX "^.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
        set (IWYU_REGEX
             "^.*include-what-you-use.*-DCUSTOM_DEFINITION=true.*Source.cpp")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${COMPILE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CPPCHECK_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_REGEX})
        cmake_unit_assert_that (${COMPILE_COMMANDS}
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_REGEX})

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK AND
        POLYSQUARE_HAVE_CLANG_TIDY AND
        POLYSQUARE_HAVE_IWYU)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Adds some custom definitions to our library. The include dirs should be
# applied to all of its sources, plus any of its checks.
function (psq_test_check_sources_run_with_correct_include_dirs)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (lib SHARED
                                                 FUNCTIONS func
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 DEFINES CUSTOM_DEFINITION=true
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${BINARY_DIR}/internal"
                                                 EXTERNAL_INCLUDE_DIRS
                                                 "${BINARY_DIR}/external"
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        if (CMAKE_GENERATOR STREQUAL "Ninja" OR
            CMAKE_GENERATOR STREQUAL "Unix Makefiles")

            set (COMPILE_COMMANDS "${BINARY_DIR}/compile_commands.json")

        else ()
            set (COMPILE_COMMANDS
                 "${BINARY_DIR}/lib_compile_commands/compile_commands.json")

        endif ()
        string (REPLACE "+" "." ESC_CXX_COMP "${CMAKE_CXX_COMPILER}")
        set (COMPILE_LOCAL_INCLUDE_REGEX
             "^.*${ESC_CXX_COMP}.* -I.*internal.*Source.cpp.*$")
        set (COMPILE_SYSTEM_INCLUDE_REGEX
             "^.*${ESC_CXX_COMP}.* -isystem.*external.*Source.cpp.*$")
        set (CPPCHECK_REGEX "^.*cppcheck.* -I.*internal.*Source.cpp.*$")
        set (CLANG_TIDY_SYSTEM_REGEX "^.*-isystem.*external.*Source.cpp.*$")
        set (CLANG_TIDY_LOCAL_REGEX "^.*-I.*internal.*$")
        set (IWYU_SYSTEM_REGEX "^.*include-.*-isystem.*external.*Source.cpp.*$")
        set (IWYU_LOCAL_REGEX "^.*include-.*-I.*internal.*Source.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${COMPILE_LOCAL_INCLUDE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${COMPILE_SYSTEM_INCLUDE_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CPPCHECK_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_LOCAL_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_SYSTEM_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_LOCAL_REGEX})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_SYSTEM_REGEX})

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK AND
        POLYSQUARE_HAVE_CLANG_TIDY AND
        POLYSQUARE_HAVE_IWYU)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Runs checks on both a source and header file. We will use special
# C++ identifiers to mark the header file as being both compatible
# with C and C++ code.
function (psq_test_check_sources_run_with_cpp_identifiers)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (lib SHARED
                                                 FUNCTIONS func
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 DEFINES FILE_IS_CPP
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${BINARY_DIR}/internal"
                                                 CPP_IDENTIFIERS FILE_IS_CPP
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)

        set (COMPILE_COMMANDS
             "${BINARY_DIR}/lib_compile_commands/compile_commands.json")
        set (CPPCHECK_REGEX "^.*cppcheck.*--language=c...*Header.h.*$")
        set (CLANG_TIDY_REGEX "^.*-x c.*Header.h.*$")
        set (IWYU_REGEX "^.*include-what-you-use.*-x c.*Header.h")
        if (NOT ${CPPCHECK_VERSION} VERSION_LESS 1.58)
            cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                    matches_regex
                                    ${CPPCHECK_REGEX})

        endif ()
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_REGEX})
        cmake_unit_assert_that (${COMPILE_COMMANDS}
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_REGEX})

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK AND
        POLYSQUARE_HAVE_CLANG_TIDY AND
        POLYSQUARE_HAVE_IWYU)

        cmake_unit_configure_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                CPPCHECK_VERSION
                                   INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Runs checks on both a source and header file. We force the language
# to C++.
function (psq_test_check_sources_run_with_forced_language)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (lib SHARED
                                                 FUNCTIONS func
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 FORCE_LANGUAGE CXX
                                                 NO_VERAPP
                                                 NO_UNUSED_CHECK)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)

        set (COMPILE_COMMANDS
             "${BINARY_DIR}/lib_compile_commands/compile_commands.json")
        set (CPPCHECK_REGEX "^.*cppcheck.*--language=c...*Header.h.*$")
        set (CLANG_TIDY_REGEX "^.*-x c.*Header.h.*$")
        set (IWYU_REGEX "^.*include-what-you-use.*-x c.*Header.h")

        if (NOT ${CPPCHECK_VERSION} VERSION_LESS 1.58)
            cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                    matches_regex
                                    ${CPPCHECK_REGEX})

        endif ()

        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                ${IWYU_REGEX})
        cmake_unit_assert_that (${COMPILE_COMMANDS}
                                file_contents
                                any_line
                                matches_regex
                                ${CLANG_TIDY_REGEX})

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK AND
        POLYSQUARE_HAVE_CLANG_TIDY AND
        POLYSQUARE_HAVE_IWYU)

        cmake_unit_configure_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                CPPCHECK_VERSION
                                   INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Specifies a list of sources to be checked as part of a group.
function (psq_test_check_sources_stampfile_generated)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        set (SOURCE_GROUP source_group)
        set (SOURCE "${SOURCE_DIR}/Source.cpp")
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        set (SOURCES "${SOURCE}")
        psq_add_checked_sources (${SOURCE_GROUP}
                                 SOURCES ${SOURCES}
                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        set (STAMPFILE "${BINARY_DIR}/source_group.stamp")
        cmake_unit_assert_that (${STAMPFILE} exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Adds some sources to be checked as part of a source group
# and ensures that both the ${SOURCE_GROUP}_scannable target
# is created as well as the ${SOURCE_GROUP} target.
function (psq_test_check_sources_target_created)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        set (SOURCE_GROUP source_group)
        set (SOURCE "${SOURCE_DIR}/Source.cpp")
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        set (SOURCES "${SOURCE}")
        psq_add_checked_sources (${SOURCE_GROUP} SOURCES ${SOURCES})
        cmake_unit_assert_that (${SOURCE_GROUP} target_exists)
        cmake_unit_assert_that (${SOURCE_GROUP}_scannable
                                target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Bootstraps polysquare's clang-tidy machinery and then adds a target with
# clang-tidy enabled, explicitly disabling the "misc-*" checks.
function (psq_test_clang_tidy_disable_checks_passed)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (lib SHARED
                                                 FUNCTIONS func
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 CLANG_TIDY_DISABLE_CHECKS
                                                 "misc-*"
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*clang-tidy.*-checks=.*-misc-.*$")

    endfunction ()

    if (POLYSQUARE_HAVE_CLANG_TIDY)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Bootstraps polysquare's clang-tidy machinery and then adds a target with
# clang-tidy enabled, explicitly enabling the "google-*" checks.
function (psq_test_clang_tidy_enable_checks_passed)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (lib SHARED
                                                 FUNCTIONS func
                                                 GENERATING_FILE
                                                 "${_CURRENT_LIST_FILE}"
                                                 CLANG_TIDY_ENABLE_CHECKS
                                                 "google-*"
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*clang-tidy.*-checks=google-.*$")

    endfunction ()

    if (POLYSQUARE_HAVE_CLANG_TIDY)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests that we can add common-universal-cmake as a
# a subdirectory.
function (psq_test_compiler_flags_set_after_compiler_bootstrap)

    function (psq_configure)

        psq_compiler_bootstrap ()

        get_property (CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
        get_property (CXXFLAGS GLOBAL PROPERTY PSQ_CXXFLAGS)

        if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")

            cmake_unit_assert_that (CFLAGS variable_contains "/WX")
            cmake_unit_assert_that (CFLAGS variable_contains "-Wall")
            cmake_unit_assert_that (CFLAGS variable_contains "/W4")

        else ()

            cmake_unit_assert_that (CXXFLAGS
                                    variable_contains "-std=c++1y")
            cmake_unit_assert_that (CFLAGS variable_contains "-fPIC")
            cmake_unit_assert_that (CFLAGS variable_contains "-fPIC")
            cmake_unit_assert_that (CFLAGS variable_contains "-Wall")
            cmake_unit_assert_that (CFLAGS variable_contains "-Werror")
            cmake_unit_assert_that (CFLAGS variable_contains "-Wextra")
            cmake_unit_assert_that (CFLAGS variable_contains
                                    "-Wno-unused-parameter")

        endif ()

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that coverage flags are not defined for non-gcc compilers even if
# we set ENABLE_COVERAGE in the cache
function (psq_test_coverage_flags_not_set_for_clang)

    function (psq_configure)

        set (CMAKE_COMPILER_IS_GNUCXX FALSE CACHE BOOL "" FORCE)
        set (CMAKE_COMPILER_IS_GNUCC FALSE CACHE BOOL "" FORCE)
        set (ENABLE_COVERAGE TRUE CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_coverage_bootstrap ()
        get_property (CFLAGS GLOBAL PROPERTY PSQ_CXXFLAGS)
        cmake_unit_assert_that (CFLAGS not variable_contains
                                "-ftest-coverage")
        cmake_unit_assert_that (CFLAGS not variable_contains
                                "-fprofile-arcs")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that coverage flags are defined for gcc and g++ if
# we set ENABLE_COVERAGE in the cache
function (psq_test_coverage_flags_set_for_gcc_after_coverage_bootstrap)

    function (psq_configure)

        set (CMAKE_COMPILER_IS_GNUCXX TRUE CACHE BOOL "" FORCE)
        set (CMAKE_COMPILER_IS_GNUCC TRUE CACHE BOOL "" FORCE)
        set (ENABLE_COVERAGE TRUE CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_coverage_bootstrap ()
        get_property (CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
        message (STATUS "${CFLAGS}--")
        cmake_unit_assert_that (CFLAGS variable_contains
                                "-ftest-coverage")
        cmake_unit_assert_that (CFLAGS variable_contains
                                "-fprofile-arcs")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Bootstraps polysquare's CPPCheck machinery and then adds a target with
# CPPCheck enabled, with the INTERNAL_INCLUDE_DIRS property set to /var
# include dir and the EXTERNAL_INCLUDE_DIRS property set to /usr
function (psq_test_cppcheck_run_with_correct_include_dirs)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS "/var"
                                                 EXTERNAL_INCLUDE_DIRS "/usr"
                                                 NO_VERAPP)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents variable_contains "cppcheck")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "--enable=style")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "Source.cpp")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "--error-exitcode=1")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "/var")

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Bootstraps polysquare's CPPCheck machinery and then adds a target with
# CPPCheck enabled, with the INTERNAL_INCLUDE_DIRS property set to /var
# include dir and the EXTERNAL_INCLUDE_DIRS property set to /usr
function (psq_test_cppchecks_all_internal_headers_on_global_unused_check)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS "/var"
                                                 EXTERNAL_INCLUDE_DIRS "/usr"
                                                 NO_VERAPP)
        psq_rules_complete_scanning ()

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*cppcheck.*unusedFunction.*-I/var.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                not
                                file_contents
                                any_line
                                matches_regex
                                "^.*cppcheck.*unusedFunction.*-I/usr.*$")

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
function (psq_test_create_asan_instrumented_binary)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_asan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=address.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=address.*target_asan.*$")

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called and psq_acceleration_bootstrap () is called then a target called
# target_asan_pch should be created.
function (psq_test_create_asan_instrumented_binary_with_pch)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        psq_acceleration_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_asan_pch target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=address.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=address.*target_asan.*$")

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
function (psq_test_create_asan_instrumented_library)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_library (${TARGET} SHARED
                                                 FUNCTIONS func
                                                 NO_VERAPP)
        cmake_unit_assert_that (${TARGET}_asan target_exists)
        cmake_unit_assert_that (${TARGET}_asan
                                item_has_property_with_value
                                TARGET
                                TYPE
                                STRING
                                EQUAL
                                "SHARED_LIBRARY")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=address.*Library.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=address.*target_asan.*$")

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_MSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_msan should be created
# along with target and -fsanitize=memory should be passed when compiling it.
function (psq_test_create_msan_instrumented_binary)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_MSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_msan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=memory.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=memory.*target_msan.*$")

    endfunction ()

    if (SANITIZERS_USE_MSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_TSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_tsan should be created
# along with target and -fsanitize=thread should be passed when compiling it.
function (psq_test_create_tsan_instrumented_binary)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_TSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_tsan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=thread.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=thread.*target_tsan.*$")

    endfunction ()

    if (SANITIZERS_USE_TSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined should be passed when compiling it.
function (psq_test_create_ubsan_instrumented_binary)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_ubsan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fsanitize=undefined.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=undefined.*target_ubsan.*$")

    endfunction ()

    if (SANITIZERS_USE_UBSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called and psq_acceleration_bootstrap () is called  then a target called
# target_asan_unity should be created
function (psq_test_create_unity_asan_instrumented_binary)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        psq_acceleration_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET} SHARED
                                                    FUNCTIONS main)
        cmake_unit_assert_that (${TARGET}_asan_unity target_exists)

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                                LANGUAGES
                                                                C
                                                                CXX
                                               CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# Sets up a normal target depending on a custom target using the DEPENDS
# keyword.
function (psq_test_dependencies_linked_to_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        cmake_unit_generate_source_file_during_build (GEN_TARGET
                                                      NAME
                                                      "custom_output.cpp")
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main
                                                    DEPENDS "${GEN_TARGET}")

    endfunction ()

    function (psq_verify)

        set (CUSTOM_COMMAND_OUTPUT "${BINARY_DIR}/custom_output.cpp")
        cmake_unit_assert_that ("${CUSTOM_COMMAND_OUTPUT}" exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Writes out CMAKE_CFG_INTDIR to ${BINARY_DIR}/CfgIntDirValue.txt
# at build time
macro (psq_export_cfg_int_dir_helper BINARY_DIR)

    set (OUTPUT_FILE "${BINARY_DIR}/CfgIntDirValue.txt")
    set (WRITE_TO_OUTPUT_FILE_SCRIPT
         "${BINARY_DIR}/WriteCfgIntDir.cmake")
    set (WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS
         "file (WRITE \"${OUTPUT_FILE}\" \"\${INTDIR}\")\n")
    file (WRITE "${WRITE_TO_OUTPUT_FILE_SCRIPT}"
          "${WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS}")
    add_custom_command (OUTPUT "${OUTPUT_FILE}"
                        COMMAND
                        "${CMAKE_COMMAND}"
                        -DINTDIR=${CMAKE_CFG_INTDIR}
                        -P
                        "${WRITE_TO_OUTPUT_FILE_SCRIPT}")
    add_custom_target (write_cfg_int_dir ALL
                       SOURCES "${OUTPUT_FILE}")

endmacro ()

# Ensures that when adding EXTERNAL_INCLUDE_DIRS to a target that
# those directories are marked as system include directories.
function (psq_test_external_headers_are_system_headers)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (INTERNAL_INCLUDE_DIR "${BINARY_DIR}/Internal")
        set (EXTERNAL_INCLUDE_DIR "${BINARY_DIR}/External")
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_VERAPP
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${INTERNAL_INCLUDE_DIR}"
                                                 EXTERNAL_INCLUDE_DIRS
                                                 "${EXTERNAL_INCLUDE_DIR}")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*isystem .*External.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*I.*Internal.*$")

    endfunction ()

    cmake_unit_configure_test (PRECONFIGURE SKIP_GENERATOR_REGEX
                                            "NMake.*|Visual.*"
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that CMAKE_EXPORT_COMPILE_COMMANDS is set after bootstrap
function (psq_test_generate_compilation_commands_database_after_bootstrap)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        cmake_unit_assert_that (CMAKE_EXPORT_COMPILE_COMMANDS is_true)
        cmake_unit_create_simple_executable (executable
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")

    endfunction ()

    function (psq_verify)

        cmake_unit_assert_that ("${BINARY_DIR}/compile_commands.json"
                                exists_as_file)

    endfunction ()

    # Support for CMAKE_EXPORT_COMPILE_COMMANDS is being enabled on a
    # per-generator basis at this point
    if (CMAKE_GENERATOR STREQUAL "Ninja" OR
        CMAKE_GENERATOR STREQUAL "Unix Makefiles")

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Bootstraps polysquare's CPPCheck machinery and then adds a new library,
# checking that a global unused function check called
# psq_check_all_unused.
function (psq_test_global_unused_function_check_by_default)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_VERAPP
                                                 INTERNAL_INCLUDE_DIRS "/var"
                                                 EXTERNAL_INCLUDE_DIRS "/usr")
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (psq_check_all_unused target_exists)

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                                LANGUAGES
                                                                C
                                                                CXX
                                               CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# Imports the written out configuration binary dir and stores it in
# CMAKE_CFG_INTDIR
macro (psq_import_cfg_int_dir_helper BINARY_DIR)

    file (READ "${BINARY_DIR}/CfgIntDirValue.txt"
          CMAKE_CFG_INTDIR) # NOLINT:unused/var_in_func

endmacro ()

# Tests that a matcher has the correct exported bits.
function (psq_test_matcher_target_has_exported_details)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_gmock_bootstrap ()
        set (MATCHER_SOURCE "${SOURCE_DIR}/Matcher.cpp")
        set (MATCHER_HEADER_DIRECTORY "${SOURCE_DIR}")
        cmake_unit_create_source_file_before_build (NAME "Matcher.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        psq_add_matcher (matcher SOURCES "${MATCHER_SOURCE}"
                         INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                         EXPORT_HEADER_DIRECTORY "${MATCHER_HEADER_DIRECTORY}")
        cmake_unit_assert_that (matcher item_has_property_with_value
                                TARGET
                                EXPORT_HEADER_DIRECTORY
                                STRING
                                EQUAL
                                "${MATCHER_HEADER_DIRECTORY}")

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests that a matcher has the correct exported bits.
function (psq_test_mock_target_has_exported_details)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_gmock_bootstrap ()
        set (MATCHER_SOURCE "${SOURCE_DIR}/Mock.cpp")
        set (MATCHER_HEADER_DIRECTORY "${SOURCE_DIR}")
        cmake_unit_create_source_file_before_build (NAME "Mock.cpp"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        psq_add_mock (mock SOURCES "${MATCHER_SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      EXPORT_HEADER_DIRECTORY "${MATCHER_HEADER_DIRECTORY}")
        cmake_unit_assert_that (mock item_has_property_with_value
                                TARGET
                                EXPORT_HEADER_DIRECTORY
                                STRING
                                EQUAL
                                "${MATCHER_HEADER_DIRECTORY}")

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# If SANITIZERS_USE_MSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_msan should be created
# along with target and -fsanitize=memory should be passed when compiling it.
function (psq_test_msan_instrumented_binary_tracks_origins)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_MSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (ORIGIN_TRACKING_REGEX
             "^.*-fsanitize-memory-track-origins=2.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "${ORIGIN_TRACKING_REGEX}")

    endfunction ()

    if (SANITIZERS_USE_MSAN AND
        SANITIZERS_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and psq_sanitizers_bootstrap ()
# is called, and psq_add_executable is called with NO_ASAN then a target
# called target_asan should not be created.
function (psq_test_no_asan_flag_disables_creation_of_instrumented_binary)

    cmake_unit_get_dirs (SOURCE_DIR BINARY_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        _psq_create_simple_instrumented_executable (${TARGET}
                                                    FUNCTIONS main
                                                    NO_ASAN)
        cmake_unit_assert_that (${TARGET}_asan not target_exists)

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                                LANGUAGES
                                                                C
                                                                CXX
                                               CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# Tests upon setting the POLYSQUARE_BUILD_TESTS cache value to FALSE
# the following targets do not exist:
#  - The "GoogleMock" external project target
#  - Any "gtest" or "gmock" targets
#  - Any targets added with psq_add_test
#  - Any targets added with psq_add_matcher
#  - Any targets added with psq_add_mock
function (psq_test_no_build_tests_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (POLYSQUARE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
        psq_gmock_bootstrap ()
        set (SOURCE "${BINARY_DIR}/Source.cpp")
        psq_add_mock (matcher SOURCES "${SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      EXPORT_HEADER_DIRECTORY "${SOURCE_DIR}")
        psq_add_mock (mock SOURCES "${SOURCE}"
                      INTERNAL_INCLUDE_DIRS "${SOURCE_DIR}"
                      EXPORT_HEADER_DIRECTORY "${SOURCE_DIR}")
        psq_add_test (unittest SOURCES "${SOURCE}" MATCHERS matcher)
        cmake_unit_assert_that (GoogleMock not target_exists)
        cmake_unit_assert_that (gtest not target_exists)
        cmake_unit_assert_that (gmock not target_exists)
        cmake_unit_assert_that (matcher not target_exists)
        cmake_unit_assert_that (mock not target_exists)
        cmake_unit_assert_that (unittest not target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests upon setting the POLYSQUARE_USE_CLANG_TIDY to FALSE that
# the following variables are unset
#  - PSQ_BOOTSTRAPPED_CPPCHECK
function (psq_test_no_clang_tidy_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (POLYSQUARE_USE_CLANG_TIDY OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_ASAN)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (PSQ_BOOTSTRAPPED_CLANG_TIDY not is_defined)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" not file_contents
                                variable_contains
                                "clang-tidy")

    endfunction ()

    if (POLYSQUARE_HAVE_CLANG_TIDY)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests upon setting the POLYSQUARE_USE_CPPCHECK cache value to FALSE
# the following targets do not exist:
#  - The "psq_check_unused" target
function (psq_test_no_cppcheck_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (POLYSQUARE_USE_CPPCHECK OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_ASAN)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (psq_check_unused not target_exists)
        cmake_unit_assert_that (PSQ_BOOTSTRAPPED_CPPCHECK not is_defined)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" not file_contents
                                variable_contains
                                "cppcheck")

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests that upon adding a library with NO_UNUSED_GENERATED_CHECK set
# that the implicit global unused function check does exist, but later
# checks in the verify stage that it is not run on generated sources.
function (psq_test_no_cppcheck_unused_generated_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        psq_create_source_file_before_build (NAME "Source.cpp"
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_generate_source_file_during_build (GEN_TARGET
                                               NAME "Generated.cpp")
        psq_add_library (library SHARED
                         SOURCES "${SOURCE_DIR}/Source.cpp"
                                 "${BINARY_DIR}/Generated.cpp"
                         NO_UNUSED_GENERATED_CHECK
                         NO_VERAPP)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (psq_check_all_unused target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                not file_contents variable_contains
                                "^.*cppcheck.*unusedFunction.*$")

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests that upon adding a library with NO_UNUSED_CHECK set
# that the implicit global unused function check target does not
# exist.
function (psq_test_no_cppcheck_unused_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        psq_create_source_file_before_build (NAME "Source.cpp"
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_generate_source_file_during_build (GEN_TARGET
                                               NAME "Generated.cpp")
        psq_add_library (library SHARED
                         SOURCES "${SOURCE_DIR}/Source.cpp"
                                 "${BINARY_DIR}/Generated.cpp"
                         NO_UNUSED_GENERATED_CHECK
                         NO_VERAPP)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (psq_check_all_unused not target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (GENERATED_UNUSED_CHECK_REGEX
             "^.*cppcheck.*unusedFunction.*Source\\.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" not file_contents
                                variable_contains
                                ${GENERATED_UNUSED_CHECK_REGEX})

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to OFF and psq_sanitizers_bootstrap ()
# is called, then a target called target_asan should not be created.
function (psq_test_no_create_asan_instrumented_binary_on_user_disable)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        set (TARGET target)
        _psq_create_simple_instrumented_executable (${TARGET}
                                                    FUNCTIONS func)
        cmake_unit_assert_that (${TARGET}_asan not target_exists)

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                                LANGUAGES
                                                                C
                                                                CXX
                                               CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# Tests upon setting the POLYSQUARE_USE_IWYU to FALSE that
# the following variables are unset
#  - PSQ_BOOTSTRAPPED_CPPCHECK
function (psq_test_no_include_what_you_use_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (POLYSQUARE_USE_IWYU OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_ASAN)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (PSQ_BOOTSTRAPPED_IWYU not is_defined)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" not file_contents
                                variable_contains
                                "include-what-you-use")

    endfunction ()

    if (POLYSQUARE_HAVE_IWYU)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Verifies that setting POLYSQUARE_USE_PRECOMPILED_HEADERS to FALSE
# causes precompiled headers not to be generated.
function (psq_test_no_pch_global_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        set (LIBRARY library)
        set (POLYSQUARE_USE_PRECOMPILED_HEADERS OFF CACHE BOOL "" FORCE)
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_ASAN)
        cmake_unit_assert_that ("${LIBRARY}_pch" not target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Verifies that passing NO_PRECOMPILED_HEADERS to the target generator
# causes precompiled headers not to be generated.
function (psq_test_no_pch_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${SOURCE_DIR}"
                                                 NO_PRECOMPILED_HEADERS)
        cmake_unit_assert_that ("library_pch" not target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Verifies that setting POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS to FALSE causes
# unity targets not to be generated.
function (psq_test_no_unity_build_global_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS OFF CACHE BOOL "" FORCE)
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${SOURCE_DIR}")
        cmake_unit_assert_that (library_unity not target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Verifies that passing NO_UNITY_BUILD causes unity targets not to be generated.
function (psq_test_no_unity_build_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${SOURCE_DIR}"
                                                 NO_UNITY_BUILD)
        cmake_unit_assert_that (library_unity not target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Tests upon setting the POLYSQUARE_USE_VERAPP cache value to FALSE
# the following targets do not exist:
#  - The vera++ import targets, being:
#    * psq_verapp_copy_rules
#    * psq_verapp_copy_profiles
#    * psq_verapp_import_rules
function (psq_test_no_verapp_option)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (POLYSQUARE_USE_VERAPP OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func)
        cmake_unit_assert_that (psq_verapp_copy_rules not target_exists)
        cmake_unit_assert_that (psq_verapp_copy_profiles not target_exists)
        cmake_unit_assert_that (psq_verapp_import_rules not target_exists)
        cmake_unit_assert_that (PSQ_VERAPP_PROFILE not is_defined)
        cmake_unit_assert_that (PSQ_VERAPP_IMPORT_RULES not is_defined)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" not file_contents
                                variable_contains
                                "vera++")

    endfunction ()

    if (POLYSQUARE_HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests upon setting the POLYSQUARE_USE_STRICT_COMPILER cache value to FALSE
# that we do not use the -Werror flag
function (psq_test_no_w_error_option)

    function (psq_configure)

        set (POLYSQUARE_USE_STRICT_COMPILER OFF CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        get_property (CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
        get_property (CXXFLAGS GLOBAL PROPERTY PSQ_CXXFLAGS)
        cmake_unit_assert_that (CXXFLAGS not variable_contains "-Werror")
        cmake_unit_assert_that (CFLAGS not variable_contains "-Werror")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Bootstraps polysquare's CPPCheck machinery and then adds a new library,
# but passing the UNUSED_CHECK_GROUP property. Verifies that a new
# target is created with the same name as the group.
function (psq_test_override_unused_check_with_group_property)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 UNUSED_CHECK_GROUP
                                                 unused_check_libraries
                                                 NO_VERAPP)
        psq_rules_complete_scanning ()
        cmake_unit_assert_that (unused_check_libraries target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (UNUSED_CHECK_LIBRARIES_STAMP
             "^.*unused_check_libraries.cppcheck-unused.stamp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                ${UNUSED_CHECK_LIBRARIES_STAMP})
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                any_line
                                matches_regex
                                "^.*cppcheck.*unusedFunction.*Source\\.cpp.*$")

    endfunction ()

    if (POLYSQUARE_HAVE_CPPCHECK)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Verifies that after calling psq_acceleration_bootstrap
# _pch targets are generated for each new polysquare target
# added.
function (psq_test_pch_targets_generated_after_cotire_bootstrap)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 INTERNAL_INCLUDE_DIRS
                                                 "${SOURCE_DIR}")
        if (XCODE)

            cmake_unit_assert_that ("library" item_has_property_with_value
                                    TARGET
                                    XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER
                                    STRING
                                    EQUAL
                                    "YES")

        else ()

            cmake_unit_assert_that ("library_pch"
                                    target_exists)

        endif ()

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE SKIP_GENERATOR_REGEX
                                                        "Visual Studio.*$"
                                                        "NMake Makefiles"
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Bootstraps polysquare's Vera++ rules and profiles and then adds
# a target dependent on the import rule so that they will be
# copied at build time
function (psq_test_polysquare_verapp_rules_copied_on_dependent_target_build)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        add_custom_target (force_import_rules ALL DEPENDS
                           psq_verapp_copy_rules
                           psq_verapp_copy_profiles
                           psq_verapp_import_rules)

    endfunction ()

    function (psq_verify)

        set (VERAPP_RULES_DIR "${BINARY_DIR}/vera++/scripts/rules")
        set (VERAPP_PROFILES_DIR "${BINARY_DIR}/vera++/profiles")
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/PSQ001.tcl" exists_as_file)
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/PSQ002.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/PSQ004.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/PSQ011.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/PSQ016.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${VERAPP_RULES_DIR}/F001.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${VERAPP_PROFILES_DIR}/polysquare"
                                exists_as_file)

    endfunction ()

    if (POLYSQUARE_HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Tests that the COTIRE_PREFIX_HEADER_IGNORE_PATH property is cleared
# on accelerated targets
function (psq_test_prefix_header_cleared_on_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (executable
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_accelerate_target_compilation ("executable")
        cmake_unit_assert_that ("executable"
                                item_has_property_with_value
                                TARGET
                                COTIRE_PREFIX_HEADER_IGNORE_PATH
                                STRING
                                EMPTY
                                EMPTY)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Places some headers in the source / build directories, but the header
# is a generated file.
function (psq_test_skip_generated_files_in_pch_file)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        cmake_unit_create_source_file_before_build (NAME "Source.cpp"
                                                    FUNCTIONS main
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_generate_source_file_during_build (GEN_TARGET
                                                      NAME "Header.h"
                                                      FUNCTIONS main
                                                      GENERATING_FILE
                                                      "${_CURRENT_LIST_FILE}")
        psq_add_executable ("executable"
                            SOURCES "${SOURCE_DIR}/Source.cpp"
                                    "${BINARY_DIR}/Header.h"
                            INTERNAL_INCLUDE_DIRS "${BINARY_DIR}")

    endfunction ()

    function (psq_verify)

        psq_import_cfg_int_dir_helper ("${BINARY_DIR}")
        set (BINARY_OUTPUT_DIR "${BINARY_DIR}/${CMAKE_CFG_INTDIR}/")

        if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")

            set (PREFIX_HEADER
                 "${BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.hxx")

        else ()

            set (PREFIX_HEADER
                 "${BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.cxx")

        endif ()

        if ("${CMAKE_GENERATOR}" STREQUAL "Ninja")

            cmake_unit_assert_that ("${BINARY_DIR}/Header.h"
                                    exists_as_file)
            cmake_unit_assert_that ("${PREFIX_HEADER}"
                                    not
                                    file_contents
                                    any_line
                                    matches_regex
                                    "^.*Header.h.*$")

        endif ()

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that the Google Test definitions, eg
function (psq_test_gtest_available_after_gmock_bootstrap)

    function (psq_configure)

        psq_gmock_bootstrap ()
        cmake_unit_assert_that (GTEST_LIBRARY matches_regex "(^.*gtest.*$)")
        cmake_unit_assert_that (GTEST_MAIN_LIBRARY matches_regex
                                "(^.*gtest_main.*$)")
        cmake_unit_assert_that (GMOCK_LIBRARY matches_regex "(^.*gmock.*$)")
        cmake_unit_assert_that (GMOCK_MAIN_LIBRARY matches_regex
                                "(^.*gmock_main.*$)")

        if (NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")

            cmake_unit_assert_that (CMAKE_THREAD_LIBS_INIT is_defined)

        endif ()

    endfunction ()

    cmake_unit_configure_config_only_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                                        ${GMOCK_FORWARD_VARS}
                                           INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined and
# -fno-sanitize-recover should be passed when compiling it.
function (psq_test_ubsan_instrumented_binary_no_recover)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*-fno-sanitize-recover.*Executable.cpp.*$")

    endfunction ()

    if (SANITIZERS_USE_UBSAN AND SANITIZERS_HAVE_UBSAN_NO_SANITIZE_RECOVER)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and psq_sanitizers_bootstrap ()
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined and
# -fsanitize=unsigned-integer-overflow should be passed when compiling it.
function (psq_test_ubsan_instrumented_binary_unsigned_int_overflow)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_sanitizers_bootstrap ()
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (UNSIGNED_INT_OVERFLOW_REGEX
             "^.*-fsanitize=unsigned-integer-overflow.*Executable.cpp.*$")
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "${UNSIGNED_INT_OVERFLOW_REGEX}")

    endfunction ()

    if (SANITIZERS_USE_UBSAN AND
        SANITIZERS_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Verifies the generated _unity target depends on the _unity version
# of other targets where those exists.
function (psq_test_unity_build_targets_depend_on_unity_dependencies)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func)
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main
                                                    LIBRARIES library)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*library_unity.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               INVOKE_BUILD OPTIONS TARGET all_unity
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Verifies that after calling psq_acceleration_bootstrap
# _unity targets are generated for each new polysquare target
# added.
function (psq_test_unity_build_targets_generated_after_cotire_bootstrap)

    cmake_unit_get_dirs (SOURCE_DIR BINARY_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        _psq_create_simple_instrumented_executable (executable)
        cmake_unit_assert_that ("executable_unity" target_exists)

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Verifies the generated _unity target inherits all non-library
# dependencies
function (psq_test_unity_build_targets_inherit_dependencies)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        cmake_unit_generate_source_file_during_build (GEN_TARGET
                                                      NAME
                                                      "custom_output.cpp")
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main
                                                    DEPENDS "${GEN_TARGET}")

    endfunction ()

    function (psq_verify)

        set (CUSTOM_COMMAND_OUTPUT "${BINARY_DIR}/custom_output.cpp")
        cmake_unit_assert_that ("${CUSTOM_COMMAND_OUTPUT}" exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Verifies the generated _unity target inherits all external target link
# libraries
function (psq_test_unity_build_targets_inherit_target_link_libraries)

    cmake_unit_get_dirs (SOURCE_DIR BINARY_DIR)

    function (psq_configure)

        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func)
        _psq_create_simple_instrumented_executable (executable
                                                    FUNCTIONS main
                                                    LIBRARIES library)
        cmake_unit_assert_that ("executable_unity" is_linked_to "library")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}" file_contents any_line
                                matches_regex
                                "^.*executable_unity.*library.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               INVOKE_BUILD OPTIONS TARGET all_unity
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

function (_psq_write_without_semicolons NAME CONTENTS)

    string (REPLACE ";" "\n" CONTENTS "${CONTENTS}")
    string (REPLACE "@SEMICOLON@" ";" CONTENTS "${CONTENTS}")

    cmake_unit_should_write ("${NAME}" "${_CURRENT_LIST_FILE}" SHOULD_WRITE)

    if (SHOULD_WRITE)

        file (WRITE "${NAME}" "${CONTENTS}\n")

    endif ()

endfunction ()

# Places some headers in the source / build directories.
function (psq_test_use_files_in_build_directory_in_pch_file)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_export_cfg_int_dir_helper ("${BINARY_DIR}")
        psq_compiler_bootstrap ()
        psq_acceleration_bootstrap ()
        set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)
        set (SOURCE "${BINARY_DIR}/Source.cpp")
        set (SOURCE_CONTENTS
             "#include \"Header.h\"\n"
             "int main ()\n"
             "{\n"
             "    return 0@SEMICOLON@\n"
             "}\n")
        _psq_write_without_semicolons ("${SOURCE}" "${SOURCE_CONTENTS}")
        set (HEADER "${BINARY_DIR}/Header.h")
        set (HEADER_CONTENTS
             "#ifndef _HEADER_H\n"
             "#define _HEADER_H\n"
             "#endif\n")
        cmake_unit_write_if_newer ("${HEADER}"
                                   "${_CURRENT_LIST_FILE}"
                                   ${HEADER_CONTENTS})
        set (EXECUTABLE executable)
        psq_add_executable ("${EXECUTABLE}"
                            SOURCES "${SOURCE}"
                                    "${HEADER}"
                            INTERNAL_INCLUDE_DIRS "${BINARY_DIR}")

    endfunction ()

    function (psq_verify)

        psq_import_cfg_int_dir_helper ("${BINARY_DIR}")
        set (BINARY_OUTPUT_DIR "${BINARY_DIR}/${CMAKE_CFG_INTDIR}/")

        if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")

            set (PREFIX_HEADER
                 "${BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.hxx")

        else ()

            set (PREFIX_HEADER
                 "${BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.cxx")

        endif ()

        cmake_unit_assert_that ("${PREFIX_HEADER}"
                                file_contents any_line matches_regex
                                "^.*Header.h.*$")

    endfunction ()

    cmake_unit_configure_test (PRECONFIGURE FORWARD_CACHE_VARIABLES
                                            COMPILER_ID
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)

endfunction ()

# Tests that we can add common-universal-cmake as a
# a subdirectory.
function (psq_test_verapp_rules_set_after_rules_bootstrap)

    function (psq_configure)

        psq_rules_bootstrap ()
        cmake_unit_assert_that (psq_verapp_copy_rules target_exists)
        cmake_unit_assert_that (psq_verapp_copy_profiles
                                target_exists)
        cmake_unit_assert_that (psq_verapp_import_rules
                                target_exists)
        cmake_unit_assert_that (PSQ_VERAPP_PROFILE
                                compare_as
                                STRING
                                EQUAL
                                "polysquare")
        cmake_unit_assert_that (PSQ_VERAPP_IMPORT_RULES
                                compare_as
                                STRING
                                EQUAL
                                "psq_verapp_import_rules")

    endfunction ()

    if (POLYSQUARE_HAVE_VERAPP)

        cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# Bootstraps polysquare's Vera++ rules and profiles and then adds
# a new executable target with VERAPP rules turned on
function (psq_test_verapp_with_polysquare_profile_run_on_target_with_rules)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        psq_rules_bootstrap ()
        _psq_create_simple_instrumented_library (library SHARED
                                                 FUNCTIONS func
                                                 NO_CPPCHECK
                                                 NO_IWYU)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents variable_contains "vera++")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "Source.cpp --profile polysquare")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "Header.h --profile polysquare")
        cmake_unit_assert_that ("${BUILD_OUTPUT}"
                                file_contents
                                variable_contains
                                "--error")

    endfunction ()

    if (POLYSQUARE_HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

set (CMAKE_FILES
     "${CMAKE_CURRENT_LIST_DIR}/PolysquareCommon.cmake"
     "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENCE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

if (COMMAND cmake_module_add_common_targets)

    cmake_module_add_common_targets (NAMESPACE "psq"
                                     CMAKE_FILES ${CMAKE_FILES}
                                     DOCUMENTATION_FILES ${MARKDOWN_FILES})

endif ()
