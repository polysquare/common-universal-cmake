# /PolysquareCommon.cmake
# Provides some functionality that is common to all polysquare projects,
# such as bootstrapping static analysis tools, adding code coverage
# targets and convenience functions to add tests, matchers, mocks etc
# without having to write too much boilerplate.
#
# See LICENCE.md for Copyright information

include (CMakeParseArguments)

option (POLYSQUARE_USE_STRICT_COMPILER "Make compiler warnings errors" ON)
option (POLYSQUARE_BUILD_TESTS "Build tests" ON)
option (POLYSQUARE_USE_VERAPP
        "Check source files for style compliance with vera++" ON)
option (POLYSQUARE_USE_CPPCHECK
        "Perform simple static analysis for known bad practices" ON)

function (polysquare_compiler_bootstrap)

    set (WERROR)

    # -Werror only mandatory if the user asked for it
    if (POLYSQUARE_USE_STRICT_COMPILER)

        set (WERROR "-Werror")

    endif (POLYSQUARE_USE_STRICT_COMPILER)

    # -fPIC and -Wall -Wextra are mandatory
    set (COMPILER_FLAGS "-fPIC -Wall -Wextra -Wno-unused-parameter ${WERROR}")
    set (CXX_CXX11_FLAGS "-std=c++0x")
    set (CMAKE_CXX_FLAGS
         "${CMAKE_CXX_FLAGS} ${COMPILER_FLAGS} ${CXX_CXX11_FLAGS}"
         PARENT_SCOPE)
    set (CMAKE_C_FLAGS
         "${CMAKE_C_FLAGS} ${COMPILER_FLAGS}"
         PARENT_SCOPE)

    # Generate a compilation commands database
    set (CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

endfunction (polysquare_compiler_bootstrap)

macro (polysquare_coverage_bootstrap COMMON_UNIVERSAL_CMAKE_DIR)

    set (CMAKE_MODULE_PATH
         ${COMMON_UNIVERSAL_CMAKE_DIR}/gcov-cmake
         ${CMAKE_MODULE_PATH})

    include (GCovUtilities)

endmacro (polysquare_coverage_bootstrap)

macro (polysquare_cppcheck_bootstrap)

    if (POLYSQUARE_USE_CPPCHECK)

        find_program (CPPCHECK_EXECUTABLE cppcheck)

        if (NOT CPPCHECK_EXECUTABLE)

            message (SEND_ERROR "cppcheck was not found")

        endif (NOT CPPCHECK_EXECUTABLE)

        mark_as_advanced (CPPCHECK_EXECUTABLE)

        include (CPPCheck)

        set (_POLYSQUARE_BOOTSTRAPPED_CPPCHECK TRUE)

    else (POLYSQUARE_USE_CPPCHECK)

        message (STATUS "CPPCheck static analysis has been disabled")

    endif (POLYSQUARE_USE_CPPCHECK)

endmacro (polysquare_cppcheck_bootstrap)

function (polysquare_cppcheck_complete_scanning)

    if (NOT POLYSQUARE_USE_CPPCHECK)

        return ()

    endif ()

    cppcheck_get_unused_function_checks (UNUSED_CHECKS)

    foreach (CHECK ${UNUSED_CHECKS})

        cppcheck_add_unused_function_check_with_name (${CHECK})

    endforeach (CHECK ${UNUSED_CHECKS})

endfunction (polysquare_cppcheck_complete_scanning)

macro (polysquare_vera_bootstrap COMMON_UNIVERSAL_CMAKE_DIR BINARY_DIR)

    if (POLYSQUARE_USE_VERAPP)

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
        set (_i_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})
        set (_copy_rules_target polysquare_verapp_copy_rules)
        set (_copy_profiles_target polysquare_verapp_copy_profiles)
        set (_r_out_dir
             ${_POLYSQUARE_VERAPP_SCRIPTS_OUTPUT_DIRECTORY}/rules/)
        set (_profiles_out_dir
             ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY}/profiles/)
        set (_rules_in_dir
             ${_POLYSQUARE_VERAPP_SCRIPTS_SOURCE_DIRECTORY}/rules/)
        set (_profiles_in_dir
             ${_POLYSQUARE_VERAPP_SOURCE_DIRECTORY}/profiles/)

        add_custom_target (${_i_target} ALL)

        verapp_import_default_rules_into_subdirectory_on_target (${_r_out_dir}
                                                                 ${_i_target})

        verapp_copy_files_in_dir_to_subdir_on_target (${_rules_in_dir}
                                                      ${_r_out_dir}
                                                      .tcl
                                                      ${_copy_rules_target}
                                                      "Vera++ rule")

        add_dependencies (${_i_target} polysquare_verapp_copy_rules)

        verapp_copy_files_in_dir_to_subdir_on_target (${_profiles_in_dir}
                                                      ${_profiles_out_dir}
                                                      NO_MATCH
                                                      ${_copy_profiles_target}
                                                      "Vera++ profile")

        add_dependencies (${_i_target} polysquare_verapp_copy_profiles)

        set (_POLYSQUARE_BOOTSTRAPPED_VERAPP TRUE)

    else (POLYSQUARE_USE_VERAPP)

        message (STATUS "Vera++ style checks have been disabled")

    endif (POLYSQUARE_USE_VERAPP)

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

function (polysquare_rules_complete_scanning)

    polysquare_cppcheck_complete_scanning ()

endfunction (polysquare_rules_complete_scanning)

macro (polysquare_gmock_bootstrap COMMON_UNIVERSAL_CMAKE_DIR)

    if (POLYSQUARE_BUILD_TESTS)

        set (GMOCK_CMAKE_DIRECTORY
             ${COMMON_UNIVERSAL_CMAKE_DIR}/gmock-cmake)

        set (CMAKE_MODULE_PATH
             ${GMOCK_CMAKE_DIRECTORY}
             ${CMAKE_MODULE_PATH})

        find_package (GoogleMock REQUIRED)

    else (POLYSQUARE_BUILD_TESTS)

        message (STATUS "Building tests has been disabled")

    endif (POLYSQUARE_BUILD_TESTS)

endmacro (polysquare_gmock_bootstrap)

function (polysquare_add_checks_to_target TARGET)

    set (ADD_CHECKS_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)

    set (ADD_CHECKS_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP)

    set (ADD_CHECKS_MULTIVAR_ARGS
         INTERNAL_INCLUDE_DIRS)

    cmake_parse_arguments (CHECKS
                           "${ADD_CHECKS_OPTION_ARGS}"
                           "${ADD_CHECKS_SINGLEVAR_ARGS}"
                           "${ADD_CHECKS_MULTIVAR_ARGS}"
                           ${ARGN})

    if (CHECKS_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${CHECKS_UNPARSED_ARUGMENTS} "
                 "given to polysquare_add_checks_to_target")

    endif (CHECKS_UNPARSED_ARGUMENTS)

    if (NOT CHECKS_NO_VERAPP AND _POLYSQUARE_BOOTSTRAPPED_VERAPP)

        set (_verapp_check_mode ERROR)

        if (CHECKS_WARN_ONLY)

            set (_verapp_check_mode WARN_ONLY)

        endif (CHECKS_WARN_ONLY)

        set (_verapp_output_dir ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY})
        set (_verapp_profile ${_POLYSQUARE_VERAPP_PROFILE})
        set (_import_rules_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})

        # CHECK_GENERATED is off by default
        set (CHECK_GENERATED_OPT)
        if (CHECKS_CHECK_GENERATED)

            set (CHECK_GENERATED_OPT CHECK_GENERATED)

        endif (CHECKS_CHECK_GENERATED)

        verapp_profile_check_source_files_conformance (${_verapp_output_dir}
                                                       ${_profile}
                                                       ${TARGET}
                                                       ${_import_rules_target}
                                                       ${_verapp_check_mode}
                                                       ${CHECK_GENERATED_OPT})

    endif (NOT CHECKS_NO_VERAPP AND _POLYSQUARE_BOOTSTRAPPED_VERAPP)

    if (NOT CHECKS_NO_CPPCHECK AND _POLYSQUARE_BOOTSTRAPPED_CPPCHECK)

        # CHECK_GENERATED is off by default
        set (CHECK_GENERATED_OPT)
        if (CHECKS_CHECK_GENERATED)

            set (CHECK_GENERATED_OPT CHECK_GENERATED)

        endif (CHECKS_CHECK_GENERATED)

        cppcheck_target_sources (${TARGET}
                                 INCLUDES
                                 ${CHECKS_INTERNAL_INCLUDE_DIRS}
                                 ${CHECK_GENERATED_OPT})

        if (NOT CHECKS_NO_UNUSED_CHECK)

            # CHECK_GENERATED is on by default unless explicitly disabled.
            set (CHECK_GENERATED_UNUSED_OPTION CHECK_GENERATED)
            if (CHECKS_NO_UNUSED_GENERATED_CHECK)

                set (CHECK_GENERATED_UNUSED_OPTION)

            endif (CHECKS_NO_UNUSED_GENERATED_CHECK)

            set (CHECK_NAME polysquare_check_all_unused)
            if (CHECKS_UNUSED_CHECK_GROUP)

                set (CHECK_NAME ${CHECKS_UNUSED_CHECK_GROUP})

            endif (CHECKS_UNUSED_CHECK_GROUP)

            set (INCDIRS ${CHECKS_INTERNAL_INCLUDE_DIRS})
            set (SOURCES ${TARGET_SOURCES})
            set (CHECKGEN ${CHECK_GENERATED_UNUSED_OPTION})

            # Using this function will have the side-effect of requiring that
            # TARGET is built before CHECK_NAME.
            cppcheck_add_target_sources_to_unused_function_check (${TARGET}
                                                                  ${CHECK_NAME}
                                                                  SOURCES
                                                                  ${SOURCES}
                                                                  INCLUDES
                                                                  ${INCDIRS}
                                                                  ${CHECKGEN})

        endif (NOT CHECKS_NO_UNUSED_CHECK)

    endif (NOT CHECKS_NO_CPPCHECK AND _POLYSQUARE_BOOTSTRAPPED_CPPCHECK)

endfunction (polysquare_add_checks_to_target)

function (_clear_variable_names_if_false PREFIX)

    foreach (VAR_NAME ${ARGN})

        set (PREFIX_VAR_NAME ${PREFIX}_${VAR_NAME})

        if (NOT ${PREFIX_VAR_NAME})

            set (${PREFIX_VAR_NAME} PARENT_SCOPE)

        else (NOT ${PREFIX_VAR_NAME})

            set (${PREFIX_VAR_NAME} ${VAR_NAME} PARENT_SCOPE)

        endif (NOT ${PREFIX_VAR_NAME})

    endforeach ()

endfunction (_clear_variable_names_if_false)

function (polysquare_add_checked_sources TARGET)

    set (SOURCES_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (SOURCES_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP)
    set (SOURCES_MULTIVAR_ARGS
         SOURCES
         INTERNAL_INCLUDE_DIRS)

    cmake_parse_arguments (SOURCES
                           "${SOURCES_OPTION_ARGS}"
                           "${SOURCES_SINGLEVAR_ARGS}"
                           "${SOURCES_MULTIVAR_ARGS}"
                           ${ARGN})

    if (SOURCES_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${SOURCES_UNPARSED_ARUGMENTS} "
                 "given to polysquare_add_checked_sources")

    endif (SOURCES_UNPARSED_ARGUMENTS)

    _clear_variable_names_if_false (SOURCES
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    set (SOURCES_SCANNED_STAMP
         ${CMAKE_BINARY_DIR}/${TARGET}.stamp)

    # Make sure that each source is marked as a "CXX" source.
    # Some of the scanners will ignore source files which aren't
    # CXX sources and we assume here that added files are valid
    # C++.
    foreach (SOURCE ${SOURCES_SOURCES})

        set_source_files_properties (${SOURCE}
                                     PROPERTIES LANGUAGE
                                     CXX)

    endforeach ()

    add_custom_target (${TARGET}_scannable
                       SOURCES ${SOURCES_SOURCES})

    add_custom_command (OUTPUT ${SOURCES_SCANNED_STAMP}
                        COMMAND
                        ${CMAKE_COMMAND} -E touch ${SOURCES_SCANNED_STAMP}
                        DEPENDS
                        ${TARGET}_scannable
                        ${SOURCES_SOURCES}
                        COMMENT "Checking source group: ${TARGET}")

    add_custom_target (${TARGET} ALL
                       DEPENDS ${SOURCES_SCANNED_STAMP})

    set_property (SOURCE ${SOURCES_SCANNED_STAMP}
                  PROPERTY OBJECT_DEPENDS
                  ${SOURCES_SOURCES})

    polysquare_add_checks_to_target (${TARGET}_scannable
                                     INTERNAL_INCLUDE_DIRS
                                     ${SOURCES_INTERNAL_INCLUDE_DIRS}
                                     UNUSED_CHECK_GROUP
                                     ${SOURCES_UNUSED_CHECK_GROUP}
                                     ${SOURCES_CHECK_GENERATED}
                                     ${SOURCES_NO_CPPCHECK}
                                     ${SOURCES_NO_UNUSED_CHECK}
                                     ${SOURCES_NO_UNUSED_GENERATED_CHECK}
                                     ${SOURCES_NO_VERAPP}
                                     ${SOURCES_WARN_ONLY})

endfunction (polysquare_add_checked_sources)

function (_polysquare_add_target_internal TARGET)

    set (TARGET_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (TARGET_SINGLEVAR_ARGS
         EXPORT_HEADER_DIRECTORY
         UNUSED_CHECK_GROUP)
    set (TARGET_MULTIVAR_ARGS
         LIBRARIES
         INTERNAL_INCLUDE_DIRS
         EXTERNAL_INCLUDE_DIRS
         SOURCES)

    cmake_parse_arguments (TARGET
                           "${TARGET_OPTION_ARGS}"
                           "${TARGET_SINGLEVAR_ARGS}"
                           "${TARGET_MULTIVAR_ARGS}"
                           ${ARGN})

    if (TARGET_LIBRARIES)

        target_link_libraries (${TARGET}
                               ${TARGET_LIBRARIES})

    endif (TARGET_LIBRARIES)

    if (TARGET_INTERNAL_INCLUDE_DIRS OR TARGET_EXTERNAL_INCLUDE_DIRS)

        # FIXME
        # Older versions of CMake such as that in Travis-CI at the moment
        # don't have per-target INCLUDE_DIRECTORIES, so we'll need to
        # add it to the directory level at this point.

        include_directories (SYSTEM ${TARGET_EXTERNAL_INCLUDE_DIRS})
        include_directories (${TARGET_INTERNAL_INCLUDE_DIRS})

        # set_property (TARGET ${TARGET}
        #               PROPERTY INCLUDE_DIRECTORIES
        #               ${TARGET_INTERNAL_INCLUDE_DIRS}
        #               ${TARGET_EXTERNAL_INCLUDE_DIRS})

    endif (TARGET_INTERNAL_INCLUDE_DIRS OR TARGET_EXTERNAL_INCLUDE_DIRS)

    if (TARGET_EXPORT_HEADER_DIRECTORY)

        set_property (TARGET ${TARGET}
                      PROPERTY EXPORT_HEADER_DIRECTORY
                      ${TARGET_EXPORT_HEADER_DIRECTORY})

    endif (TARGET_EXPORT_HEADER_DIRECTORY)

    _clear_variable_names_if_false (TARGET
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    polysquare_add_checks_to_target (${TARGET}
                                     INTERNAL_INCLUDE_DIRS
                                     ${TARGET_INTERNAL_INCLUDE_DIRS}
                                     UNUSED_CHECK_GROUP
                                     ${TARGET_UNUSED_CHECK_GROUP}
                                     ${TARGET_CHECK_GENERATED}
                                     ${TARGET_NO_CPPCHECK}
                                     ${TARGET_NO_UNUSED_CHECK}
                                     ${TARGET_NO_UNUSED_GENERATED_CHECK}
                                     ${TARGET_NO_VERAPP}
                                     ${TARGET_WARN_ONLY})

endfunction (_polysquare_add_target_internal)

function (polysquare_add_library LIBRARY_NAME LIBRARY_TYPE)

    set (LIBRARY_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (LIBRARY_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY)
    set (LIBRARY_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES)

    cmake_parse_arguments (LIBRARY
                           "${LIBRARY_OPTION_ARGS}"
                           "${LIBRARY_SINGLEVAR_ARGS}"
                           "${LIBRARY_MULTIVAR_ARGS}"
                           ${ARGN})

    if (LIBRARY_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${LIBRARY_UNPARSED_ARGUMENTS} "
                 "given to polysquare_add_library")

    endif (LIBRARY_UNPARSED_ARGUMENTS)

    add_library (${LIBRARY_NAME}
                 ${LIBRARY_TYPE}
                 ${LIBRARY_SOURCES})

    _clear_variable_names_if_false (LIBRARY
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    _polysquare_add_target_internal (${LIBRARY_NAME}
                                     EXTERNAL_INCLUDE_DIRS
                                     ${LIBRARY_EXTERNAL_INCLUDE_DIRS}
                                     INTERNAL_INCLUDE_DIRS
                                     ${LIBRARY_INTERNAL_INCLUDE_DIRS}
                                     LIBRARIES ${LIBRARY_LIBRARIES}
                                     SOURCES ${LIBRARY_SOURCES}
                                     EXPORT_HEADER_DIRECTORY
                                     ${LIBRARY_EXPORT_HEADER_DIRECTORY}
                                     UNUSED_CHECK_GROUP
                                     ${LIBRARY_UNUSED_CHECK_GROUP}
                                     ${LIBRARY_CHECK_GENERATED}
                                     ${LIBRARY_NO_CPPCHECK}
                                     ${LIBRARY_NO_UNUSED_CHECK}
                                     ${LIBRARY_NO_UNUSED_GENERATED_CHECK}
                                     ${LIBRARY_NO_VERAPP}
                                     ${LIBRARY_WARN_ONLY})

endfunction (polysquare_add_library)

function (polysquare_add_executable EXECUTABLE_NAME)

    set (EXECUTABLE_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (EXECUTABLE_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY)
    set (EXECUTABLE_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES)

    cmake_parse_arguments (EXECUTABLE
                           "${EXECUTABLE_OPTION_ARGS}"
                           "${EXECUTABLE_SINGLEVAR_ARGS}"
                           "${EXECUTABLE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (EXECUTABLE_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${EXECUTABLE_UNPARSED_ARGUMENTS} "
                 "given to polysquare_add_executable")

    endif (EXECUTABLE_UNPARSED_ARGUMENTS)

    add_executable (${EXECUTABLE_NAME}
                    ${EXECUTABLE_SOURCES})

    _clear_variable_names_if_false (EXECUTABLE
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    _polysquare_add_target_internal (${EXECUTABLE_NAME}
                                     EXTERNAL_INCLUDE_DIRS
                                     ${EXECUTABLE_EXTERNAL_INCLUDE_DIRS}
                                     INTERNAL_INCLUDE_DIRS
                                     ${EXECUTABLE_INTERNAL_INCLUDE_DIRS}
                                     LIBRARIES ${EXECUTABLE_LIBRARIES}
                                     SOURCES ${EXECUTABLE_SOURCES}
                                     EXPORT_HEADER_DIRECTORY
                                     ${EXECUTABLE_EXPORT_HEADER_DIRECTORY}
                                     UNUSED_CHECK_GROUP
                                     ${EXECUTABLE_UNUSED_CHECK_GROUP}
                                     ${EXECUTABLE_CHECK_GENERATED}
                                     ${EXECUTABLE_NO_CPPCHECK}
                                     ${EXECUTABLE_NO_UNUSED_CHECK}
                                     ${EXECUTABLE_NO_UNUSED_GENERATED_CHECK}
                                     ${EXECUTABLE_NO_VERAPP}
                                     ${EXECUTABLE_WARN_ONLY})

endfunction (polysquare_add_executable)

macro (_polysquare_add_gtest_includes_and_libraries EXTERNAL_INCLUDE_DIRS_VAR
                                                    LIBRARIES_VAR)

    list (APPEND ${EXTERNAL_INCLUDE_DIRS_VAR}
          ${GTEST_INCLUDE_DIR}
          ${GMOCK_INCLUDE_DIR})

    list (APPEND ${LIBRARIES_VAR}
          ${GTEST_LIBRARY}
          ${GMOCK_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT})

endmacro (_polysquare_add_gtest_includes_and_libraries)

macro (_polysquare_add_library_export_headers LIBRARY
                                              INCLUDE_DIRS_VAR
                                              LIBRARIES_VAR)

    list (APPEND ${LIBRARIES_VAR}
          ${LIBRARY})

    get_property (EXPORT_HEADER_DIRECTORY
                  TARGET ${LIBRARY}
                  PROPERTY EXPORT_HEADER_DIRECTORY)

    list (APPEND ${INCLUDE_DIRS_VAR}
          ${EXPORT_HEADER_DIRECTORY})

endmacro (_polysquare_add_library_export_headers)

function (polysquare_add_test TEST_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (TEST_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (TEST_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY
         MAIN_LIBRARY)
    set (TEST_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES
         MATCHERS
         MOCKS)

    cmake_parse_arguments (TEST
                           "${TEST_OPTION_ARGS}"
                           "${TEST_SINGLEVAR_ARGS}"
                           "${TEST_MULTIVAR_ARGS}"
                           ${ARGN})

    if (TEST_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${TEST_UNPARSED_ARUGMENTS} given to "
                 "polysquare_add_test")

    endif (TEST_UNPARSED_ARGUMENTS)

    _polysquare_add_gtest_includes_and_libraries (TEST_EXTERNAL_INCLUDE_DIRS
                                                  TEST_LIBRARIES)

    if (TEST_MAIN_LIBRARY)

        list (APPEND TEST_LIBRARIES ${TEST_MAIN_LIBRARY})

    else (TEST_MAIN_LIBRARY)

        list (APPEND TEST_LIBRARIES ${GMOCK_MAIN_LIBRARY})

    endif (TEST_MAIN_LIBRARY)

    foreach (MATCHER ${TEST_MATCHERS})

        _polysquare_add_library_export_headers (${MATCHER}
                                                TEST_INTERNAL_INCLUDE_DIRS
                                                TEST_LIBRARIES)

    endforeach ()

    foreach (MOCK ${TEST_MOCKS})

        _polysquare_add_library_export_headers (${MOCK}
                                                TEST_INTERNAL_INCLUDE_DIRS
                                                TEST_LIBRARIES)

    endforeach ()

    _clear_variable_names_if_false (TEST
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    polysquare_add_executable (${TEST_NAME}
                               EXTERNAL_INCLUDE_DIRS
                               ${TEST_EXTERNAL_INCLUDE_DIRS}
                               INTERNAL_INCLUDE_DIRS
                               ${TEST_INTERNAL_INCLUDE_DIRS}
                               LIBRARIES ${TEST_LIBRARIES}
                               SOURCES ${TEST_SOURCES}
                               EXPORT_HEADER_DIRECTORY
                               ${TEST_EXPORT_HEADER_DIRECTORY}
                               UNUSED_CHECK_GROUP
                               ${TEST_UNUSED_CHECK_GROUP}
                               ${TEST_CHECK_GENERATED}
                               ${TEST_NO_CPPCHECK}
                               ${TEST_NO_UNUSED_CHECK}
                               ${TEST_NO_UNUSED_GENERATED_CHECK}
                               ${TEST_NO_VERAPP}
                               ${TEST_WARN_ONLY})

endfunction (polysquare_add_test)

function (polysquare_add_test_main MAIN_LIBRARY_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MAIN_LIBRARY_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (MAIN_LIBRARY_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY)
    set (MAIN_LIBRARY_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES)

    cmake_parse_arguments (MAIN_LIBRARY
                           "${MAIN_LIBRARY_OPTION_ARGS}"
                           "${MAIN_LIBRARY_SINGLEVAR_ARGS}"
                           "${MAIN_LIBRARY_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MAIN_LIBRARY_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MAIN_LIBRARY_UNPARSED_ARUGMENTS}"
                 " given to polysquare_add_main_library")

    endif (MAIN_LIBRARY_UNPARSED_ARGUMENTS)

    set (MAIN_LIB_EXT_INC_DIRS ${MAIN_LIBRARY_EXTERNAL_INCLUDE_DIRS})

    _polysquare_add_gtest_includes_and_libraries (MAIN_LIB_EXT_INC_DIRS
                                                  MAIN_LIBRARY_LIBRARIES)

    _clear_variable_names_if_false (MAIN_LIBRARY
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    polysquare_add_library (${MAIN_LIBRARY_NAME} STATIC
                            EXTERNAL_INCLUDE_DIRS
                            ${MAIN_LIBRARY_EXTERNAL_INCLUDE_DIRS}
                            INTERNAL_INCLUDE_DIRS
                            ${MAIN_LIBRARY_INTERNAL_INCLUDE_DIRS}
                            LIBRARIES ${MAIN_LIBRARY_LIBRARIES}
                            SOURCES ${MAIN_LIBRARY_SOURCES}
                            EXPORT_HEADER_DIRECTORY
                            ${MAIN_LIBRARY_EXPORT_HEADER_DIRECTORY}
                            UNUSED_CHECK_GROUP
                            ${MAIN_LIBRARY_UNUSED_CHECK_GROUP}
                            ${MAIN_LIBRARY_CHECK_GENERATED}
                            ${MAIN_LIBRARY_NO_CPPCHECK}
                            ${MAIN_LIBRARY_NO_UNUSED_CHECK}
                            ${MAIN_LIBRARY_NO_UNUSED_GENERATED_CHECK}
                            ${MAIN_LIBRARY_NO_VERAPP}
                            ${MAIN_LIBRARY_WARN_ONLY})

endfunction (polysquare_add_test_main)

function (polysquare_add_matcher MATCHER_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MATCHER_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (MATCHER_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY)
    set (MATCHER_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES)

    cmake_parse_arguments (MATCHER
                           "${MATCHER_OPTION_ARGS}"
                           "${MATCHER_SINGLEVAR_ARGS}"
                           "${MATCHER_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MATCHER_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MATCHER_UNPARSED_ARUGMENTS} given to"
                 " polysquare_add_matcher")

    endif (MATCHER_UNPARSED_ARGUMENTS)

    _polysquare_add_gtest_includes_and_libraries (MATCHER_EXTERNAL_INCLUDE_DIRS
                                                  MATCHER_LIBRARIES)

    _clear_variable_names_if_false (MATCHER
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    polysquare_add_library (${MATCHER_NAME} STATIC
                            EXTERNAL_INCLUDE_DIRS
                            ${MATCHER_EXTERNAL_INCLUDE_DIRS}
                            INTERNAL_INCLUDE_DIRS
                            ${MATCHER_INTERNAL_INCLUDE_DIRS}
                            LIBRARIES ${MATCHER_LIBRARIES}
                            SOURCES ${MATCHER_SOURCES}
                            EXPORT_HEADER_DIRECTORY
                            ${MATCHER_EXPORT_HEADER_DIRECTORY}
                            UNUSED_CHECK_GROUP
                            ${MATCHER_UNUSED_CHECK_GROUP}
                            ${MATCHER_CHECK_GENERATED}
                            ${MATCHER_NO_CPPCHECK}
                            ${MATCHER_NO_UNUSED_CHECK}
                            ${MATCHER_NO_UNUSED_GENERATED_CHECK}
                            ${MATCHER_NO_VERAPP}
                            ${MATCHER_WARN_ONLY})

endfunction (polysquare_add_matcher)

function (polysquare_add_mock MOCK_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MOCK_OPTION_ARGS
         CHECK_GENERATED
         NO_CPPCHECK
         NO_UNUSED_CHECK
         NO_UNUSED_GENERATED_CHECK
         NO_VERAPP
         WARN_ONLY)
    set (MOCK_SINGLEVAR_ARGS
         UNUSED_CHECK_GROUP
         EXPORT_HEADER_DIRECTORY)
    set (MOCK_MULTIVAR_ARGS
         EXTERNAL_INCLUDE_DIRS
         INTERNAL_INCLUDE_DIRS
         LIBRARIES
         SOURCES)

    cmake_parse_arguments (MOCK
                           "${MOCK_OPTION_ARGS}"
                           "${MOCK_SINGLEVAR_ARGS}"
                           "${MOCK_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MOCK_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MOCK_UNPARSED_ARUGMENTS} given to "
                 "polysquare_add_mock")

    endif (MOCK_UNPARSED_ARGUMENTS)

    _polysquare_add_gtest_includes_and_libraries (MOCK_EXTERNAL_INCLUDE_DIRS
                                                  MOCK_LIBRARIES)

    _clear_variable_names_if_false (MOCK
                                    CHECK_GENERATED
                                    NO_CPPCHECK
                                    NO_UNUSED_CHECK
                                    NO_UNUSED_GENERATED_CHECK
                                    NO_VERAPP
                                    WARN_ONLY)

    polysquare_add_library (${MOCK_NAME} STATIC
                            EXTERNAL_INCLUDE_DIRS ${MOCK_EXTERNAL_INCLUDE_DIRS}
                            INTERNAL_INCLUDE_DIRS ${MOCK_INTERNAL_INCLUDE_DIRS}
                            LIBRARIES ${MOCK_LIBRARIES}
                            SOURCES ${MOCK_SOURCES}
                            EXPORT_HEADER_DIRECTORY
                            ${MOCK_EXPORT_HEADER_DIRECTORY}
                            UNUSED_CHECK_GROUP
                            ${MOCK_UNUSED_CHECK_GROUP}
                            ${MOCK_CHECK_GENERATED}
                            ${MOCK_NO_CPPCHECK}
                            ${MOCK_NO_UNUSED_CHECK}
                            ${MOCK_NO_UNUSED_GENERATED_CHECK}
                            ${MOCK_NO_VERAPP}
                            ${MOCK_WARN_ONLY})

endfunction (polysquare_add_mock)
