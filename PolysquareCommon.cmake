# /PolysquareCommon.cmake
# Provides some functionality that is common to all polysquare projects,
# such as bootstrapping static analysis tools, adding code coverage
# targets and convience functions to add tests, matchers, mocks etc
# without having to write too much boilerplate.
#
# See LICENCE.md for Copyright information

include (CMakeParseArguments)

function (polysquare_compiler_bootstrap)

    # -fPIC, -Wall and -Werror are mandatory
    set (COMPILER_FLAGS "-fPIC -Wall -Werror")
    set (CXX_CXX11_FLAGS "-std=c++0x")
    set (CMAKE_CXX_FLAGS
         "${CMAKE_CXX_FLAGS} ${COMPILER_FLAGS} ${CXX_CXX11_FLAGS}"
         PARENT_SCOPE)
    set (CMAKE_C_FLAGS
         "${CMAKE_C_FLAGS} ${COMPILER_FLAGS}"
         PARENT_SCOPE)

endfunction (polysquare_compiler_bootstrap)

macro (polysquare_cppcheck_bootstrap)

    find_program (CPPCHECK_EXECUTABLE cppcheck)

    if (NOT CPPCHECK_EXECUTABLE)

        message (SEND_ERROR "cppcheck was not found")

    endif (NOT CPPCHECK_EXECUTABLE)

    mark_as_advanced (CPPCHECK_EXECUTABLE)

    include (CPPCheck)

    # Append all sources to unused function check
    add_custom_target (polysquare_check_unused ALL
                       COMMENT "Checking for unused functions")

endmacro (polysquare_cppcheck_bootstrap)

macro (polysquare_vera_bootstrap COMMON_UNIVERSAL_CMAKE_DIR BINARY_DIR)

    # Bootstrap vera++
    find_package (VeraPP 1.2 REQUIRED)
    include (VeraPPUtilities)

    set (_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY
         ${BINARY_DIR}/vera++)
    set (_POLYSQUARE_VERAPP_SCRIPTS_OUTPUT_DIRECTORY
         ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY}/scripts)
    set (_POLYSQUARE_VERAPP_SOURCE_DIRECTORY
         ${COMMON_UNIVERSAL_CMAKE_DIR}/vera++)
    set (_POLYSQUARE_VERAPP_SCRIPTS_SOURCE_DIRECTORY
         ${_POLYSQUARE_VERAPP_SOURCE_DIRECTORY}/scripts)
    set (_POLYSQUARE_VERAPP_PROFILE polysquare)
    set (_POLYSQUARE_VERAPP_IMPORT_RULES polysquare_verapp_import_rules)

    set (_profile ${_POLYSQUARE_VERAPP_PROFILE})
    set (_import_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})
    set (_rules_out_dir ${_POLYSQUARE_VERAPP_SCRIPTS_OUTPUT_DIRECTORY}/rules/)
    set (_profiles_out_dir ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY}/profiles/)
    set (_rules_in_dir ${_POLYSQUARE_VERAPP_SCRIPTS_SOURCE_DIRECTORY}/rules/)
    set (_profiles_in_dir ${_POLYSQUARE_VERAPP_SOURCE_DIRECTORY}/profiles/)

    add_custom_target (${_import_target} ALL)

    verapp_import_default_rules_into_subdirectory_on_target (${_rules_out_dir}
                                                             ${_import_target})

    verapp_copy_files_in_dir_to_subdir_on_target (${_rules_in_dir}
                                                  ${_rules_out_dir}
                                                  .tcl
                                                  polysquare_verapp_copy_rules
                                                  "Vera++ rule")

    add_dependencies (${_import_target} polysquare_verapp_copy_rules)

    verapp_copy_files_in_dir_to_subdir_on_target (${_profiles_in_dir}
                                                  ${_profiles_out_dir}
                                                  NO_MATCH
                                                  polysquare_verapp_copy_profiles
                                                  "Vera++ profile")

    add_dependencies (${_import_target} polysquare_verapp_copy_profile)



endmacro (polysquare_vera_bootstrap)

macro (polysquare_rules_bootstrap COMMON_UNIVERSAL_CMAKE_DIR BINARY_DIR)

    set (VERAPP_CMAKE_DIRECTORY
         ${COMMON_UNIVERSAL_CMAKE_DIR}/veracpp-cmake)
    set (CPPCHECK_CMAKE_DIRECTORY
         ${COMMON_UNIVERSAL_CMAKE_DIR}/cppcheck-target-cmake)

    set (CMAKE_MODULE_PATH
         ${VERAPP_CMAKE_DIRECTORY}
         ${CPPCHECK_CMAKE_DIRECTORY}
         ${CMAKE_MODULE_PATH})

    polysquare_vera_bootstrap (${COMMON_UNIVERSAL_CMAKE_DIR} ${BINARY_DIR})
    polysquare_cppcheck_bootstrap ()

endmacro (polysquare_rules_bootstrap)

macro (polysquare_gmock_bootstrap COMMON_UNIVERSAL_CMAKE_DIR)

    set (GMOCK_CMAKE_DIRECTORY
         ${COMMON_UNIVERSAL_CMAKE_DIR}/gmock-cmake)

    set (CMAKE_MODULE_PATH
         ${GMOCK_CMAKE_DIRECTORY}
         ${CMAKE_MODULE_PATH})

    find_package (GoogleMock REQUIRED)

endmacro (polysquare_gmock_bootstrap)

function (_polysquare_add_checks_to_target TARGET)

    set (ADD_CHECKS_OPTION_ARGS
         CPPCHECK;VERAPP;WARN_ONLY)

    set (ADD_CHECKS_MULTIVAR_ARGS
         INTERNAL_INCLUDE_DIRS)

    cmake_parse_arguments (ADD_CHECK
                           "${ADD_CHECKS_OPTION_ARGS}"
                           ""
                           "${ADD_CHECKS_MULTIVAR_ARGS})"
                           ${ARGN})

    if (ADD_CHECK_VERAPP)

        set (_verapp_check_mode ERROR)

        if (ADD_CHECKS_OPTION_ARGS_WARN_ONLY)

            set (_verapp_check_mode ERROR)

        endif (ADD_CHECKS_OPTION_ARGS_WARN_ONLY)

        set (_verapp_output_dir ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY})
        set (_source_dir ${CMAKE_CURRENT_SOURCE_DIR})
        set (_verapp_profile ${_POLYSQUARE_VERAPP_PROFILE})
        set (_import_rules_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})


        verapp_profile_check_source_files_conformance (${_verapp_output_dir}
                                                       ${_source_dir}
                                                       ${_profile}
                                                       ${TARGET}
                                                       ${_import_rules_target}
                                                       ${_verapp_check_mode})

    endif (ADD_CHECK_VERAPP)

    if (ADD_CHECK_CPPCEHCK)

        cppcheck_target_sources (${TARGET}
                                 INCLUDES
                                 ${ADD_CHECKS_INTERNAL_INCLUDE_DIRS})

    endif (ADD_CHECK_CPPCHECK)

endfunction (_polysquare_add_checks_to_target)

function (polysquare_add_test TEST_NAME)

    set (TEST_MULTIVAR_ARGS
         INCLUDE_DIRECTORIES;SOURCES;LIBRARIES;MATCHERS;MOCKS)

    cmake_parse_arguments (TEST
                           ""
                           ""
                           "${TEST_MULTIVAR_ARGS}"
                           ${ARGN})

    list (APPEND TEST_INCLUDE_DIRECTORIES
          ${GTEST_INCLUDE_DIR}
          ${GMOCK_INCLUDE_DIR})
    list (APPEND TEST_LIBRARIES
          ${GTEST_LIBRARY}
          ${GMOCK_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT}
          ${GMOCK_MAIN_LIBRARY})

    foreach (MATCHER ${TEST_MATCHERS})

        list (APPEND TEST_LIBRARIES
              ${MATCHER})

        get_property (MATCHER_EXPORT_HEADER_DIRECTORY
                      TARGET ${MATCHER}
                      PROPERTY EXPORT_HEADER_DIRECTORY)

        list (APPEND TEST_INCLUDE_DIRECTORIES
              ${MATCHER_EXPORT_HEADER_DIRECTORY})

    endforeach ()

    foreach (MOCK ${TEST_MOCKS})

        list (APPEND TEST_LIBRARIES
              ${MOCK})

        get_property (MOCK_EXPORT_HEADER_DIRECTORY
                      TARGET ${MOCK}
                      PROPERTY EXPORT_HEADER_DIRECTORY)

        list (APPEND TEST_INCLUDE_DIRECTORIES
              ${MOCK_EXPORT_HEADER_DIRECTORY})

    endforeach ()

    include_directories (${TEST_INCLUDE_DIRECTORIES})

    add_executable (${TEST_NAME}
                    ${TEST_SOURCES})

    target_link_libraries (${TEST_NAME}
                           ${TEST_LIBRARIES})

endfunction (polysquare_add_test)

function (polysquare_add_matcher MATCHER_NAME)

    set (MATCHER_SINGLE_VALUE_ARGS
         EXPORT_HEADER_DIRECTORY)
    set (MATCHER_MULTIVALUE_ARGS
         INCLUDE_DIRECTORIES;SOURCES;LIBRARIES)

    cmake_parse_arguments (MATCHER
                           ""
                           "${MATCHER_SINGLE_VALUE_ARGS}"
                           "${MATCHER_MULTIVALUE_ARGS}"
                           ${ARGN})

    list (APPEND MATCHER_INCLUDE_DIRECTORIES
          ${GTEST_INCLUDE_DIR}
          ${GMOCK_INCLUDE_DIR})
    list (APPEND MATCHER_LIBRARIES
          ${GTEST_LIBRARY}
          ${GMOCK_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT})

    include_directories (${MATCHER_INCLUDE_DIRECTORIES})

    add_library (${MATCHER_NAME} STATIC
                 ${MATCHER_SOURCES})

    target_link_libraries (${MATCHER_NAME}
                           ${MATCHER_LIBRARIES})

    set_property (TARGET ${MATCHER_NAME}
                  PROPERTY EXPORT_HEADER_DIRECTORY
                  ${MATCHER_EXPORT_HEADER_DIRECTORY})

endfunction (polysquare_add_matcher)

function (polysquare_add_mock MOCK_NAME)

    set (MOCK_SINGLE_VALUE_ARGS
         EXPORT_HEADER_DIRECTORY)
    set (MOCK_MULTIVALUE_ARGS
         INCLUDE_DIRECTORIES;SOURCES;LIBRARIES)

    cmake_parse_arguments (MOCK
                           ""
                           "${MOCK_SINGLE_VALUE_ARGS}"
                           "${MOCK_MULTIVALUE_ARGS}"
                           ${ARGN})

    list (APPEND MOCK_INCLUDE_DIRECTORIES
          ${GTEST_INCLUDE_DIR}
          ${GMOCK_INCLUDE_DIR})
    list (APPEND MOCK_LIBRARIES
          ${GTEST_LIBRARY}
          ${GMOCK_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT})

    include_directories (${MOCK_INCLUDE_DIRECTORIES})

    add_library (${MOCK_NAME} STATIC
                 ${MOCK_SOURCES})

    target_link_libraries (${MOCK_NAME}
                           ${MOCK_LIBRARIES})

    set_property (TARGET ${MOCK_NAME}
                  PROPERTY EXPORT_HEADER_DIRECTORY
                  ${MOCK_EXPORT_HEADER_DIRECTORY})

endfunction (polysquare_add_mock)


