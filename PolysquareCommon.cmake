# /PolysquareCommon.cmake
# Provides some functionality that is common to all polysquare projects,
# such as bootstrapping static analysis tools, adding code coverage
# targets and convenience functions to add tests, matchers, mocks etc
# without having to write too much boilerplate.
#
# See LICENCE.md for Copyright information

include (CMakeParseArguments)

# This file's directory
set (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

function (polysquare_compiler_bootstrap)

    option (POLYSQUARE_USE_STRICT_COMPILER "Make compiler warnings errors" ON)

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

macro (polysquare_sanitizers_bootstrap)

    set (CMAKE_MODULE_PATH
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/sanitize-target-cmake
         ${CMAKE_MODULE_PATH})

    include (SanitizeTarget)

endmacro (polysquare_sanitizers_bootstrap)

macro (polysquare_acceleration_bootstrap)

    option (POLYSQUARE_USE_PRECOMPILED_HEADERS
            "Generate precompiled headers for targets where appropriate" ON)
    option (POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS
            "Generate single-source-file targets, invoked with target_unity" ON)

    if (POLYSQUARE_USE_PRECOMPILED_HEADERS OR
        POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

        set (CMAKE_MODULE_PATH
             ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/accelerate-target-cmake
             ${CMAKE_MODULE_PATH})

        include (AccelerateTarget)

    endif (POLYSQUARE_USE_PRECOMPILED_HEADERS OR
           POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

endmacro (polysquare_acceleration_bootstrap)

macro (polysquare_coverage_bootstrap)

    set (CMAKE_MODULE_PATH
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/gcov-cmake
         ${CMAKE_MODULE_PATH})

    include (GCovUtilities)

endmacro (polysquare_coverage_bootstrap)

macro (polysquare_cppcheck_bootstrap)

    option (POLYSQUARE_USE_CPPCHECK
            "Perform simple static analysis for known bad practices" ON)

    if (POLYSQUARE_USE_CPPCHECK)

        include (CPPCheck)

        _validate_cppcheck (CONTINUE)

        if (NOT CONTINUE)

            set (_POLYSQUARE_CPPCHECK_REASON "is unavailable")
            set (POLYSQUARE_USE_CPPCHECK OFF)

        endif (NOT CONTINUE)

    else (POLYSQUARE_USE_CPPCHECK)

        set (_POLYSQUARE_CPPCHECK_REASON "has been disabled")

    endif (POLYSQUARE_USE_CPPCHECK)

    if (NOT POLYSQUARE_USE_CPPCHECK)

        message (STATUS "cppcheck analysis ${_POLYSQUARE_CPPCHECK_REASON}")

    endif (NOT POLYSQUARE_USE_CPPCHECK)

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

macro (polysquare_clang_tidy_bootstrap)

    option (POLYSQUARE_USE_CLANG_TIDY
            "Perform simple static analysis using clang" ON)

    if (POLYSQUARE_USE_CLANG_TIDY)

        include (ClangTidy)

        _validate_clang_tidy (CONTINUE)

        if (CONTINUE)

            set (POLYSQUARE_CLANG_TIDY_DEFAULT_ENABLED_CHECKS)
            set (POLYSQUARE_CLANG_TIDY_DEFAULT_DISABLED_CHECKS
                 "llvm-*"
                 "google-*")

        else (CONTINUE)

            set (_POLYSQUARE_CLANG_TIDY_REASON "is unavailable")
            set (POLYSQUARE_USE_CLANG_TIDY OFF)

        endif (CONTINUE)

    else (POLYSQUARE_USE_CLANG_TIDY)

        set (_POLYSQUARE_CLANG_TIDY_REASON "has been disabled")

    endif (POLYSQUARE_USE_CLANG_TIDY)

    if (NOT POLYSQUARE_USE_CLANG_TIDY)

        message (STATUS "clang-tidy analysis ${_POLYSQUARE_CLANG_TIDY_REASON}.")

    endif (NOT POLYSQUARE_USE_CLANG_TIDY)

endmacro (polysquare_clang_tidy_bootstrap)

macro (polysquare_include_what_you_use_bootstrap)

    option (POLYSQUARE_USE_IWYU
            "Perform checks to ensure that there are no unecessary #includes"
            ON)

    if (POLYSQUARE_USE_IWYU)

        include (IncludeWhatYouUse)

        _validate_include_what_you_use (CONTINUE)

        if (NOT CONTINUE)

            set (_POLYSQUARE_IWYU_REASON "is unavailable")
            set (POLYSQUARE_USE_IWYU OFF)

        endif (NOT CONTINUE)

    else (POLYSQUARE_USE_IWYU)

        set (_POLYSQUARE_IWYU_REASON "has been disabled")

    endif (POLYSQUARE_USE_IWYU)

    if (NOT POLYSQUARE_USE_IWYU)

        message (STATUS "include-what-you-use analysis"
                        " ${_POLYSQUARE_IWYU_REASON}.")

    endif (NOT POLYSQUARE_USE_IWYU)

endmacro (polysquare_include_what_you_use_bootstrap)

macro (polysquare_vera_bootstrap)

    option (POLYSQUARE_USE_VERAPP
            "Check source files for style compliance with vera++" ON)

    if (POLYSQUARE_USE_VERAPP)

        include (VeraPPUtilities)
        _validate_verapp (CONTINUE 1.2)

        if (NOT CONTINUE)

            set (_POLYSQUARE_VERAPP_REASON "are unavailable")
            set (POLYSQUARE_USE_VERAPP OFF)

        endif (NOT CONTINUE)

    else (POLYSQUARE_USE_VERAPP)

        set (_POLYSQUARE_VERAPP_REASON "have been disabled")

    endif (POLYSQUARE_USE_VERAPP)

    if (POLYSQUARE_USE_VERAPP)

        set (_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY
             ${CMAKE_CURRENT_BINARY_DIR}/vera++)
        set (_POLYSQUARE_VERAPP_SCRIPTS_OUTPUT_DIRECTORY
             ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY}/scripts)
        set (_POLYSQUARE_VERAPP_SOURCE_DIRECTORY
             ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/vera++)
        set (_POLYSQUARE_VERAPP_SCRIPTS_SOURCE_DIRECTORY
             ${_POLYSQUARE_VERAPP_SOURCE_DIRECTORY}/scripts)
        set (_POLYSQUARE_VERAPP_PROFILE polysquare)
        set (_POLYSQUARE_VERAPP_IMPORT_RULES polysquare_verapp_import_rules)

        set (_profile ${_POLYSQUARE_VERAPP_PROFILE})
        set (_i_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})
        set (_copy_rules_target polysquare_verapp_copy_rules)
        set (_copy_profiles_target polysquare_verapp_copy_profiles)
        set (_r_out_dir
             ${_POLYSQUARE_VERAPP_SCRIPTS_OUTPUT_DIRECTORY}/rules)
        set (_profiles_out_dir
             ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY}/profiles)
        set (_rules_in_dir
             ${_POLYSQUARE_VERAPP_SCRIPTS_SOURCE_DIRECTORY}/rules)
        set (_profiles_in_dir
             ${_POLYSQUARE_VERAPP_SOURCE_DIRECTORY}/profiles)

        add_custom_target (${_i_target} ALL)

        verapp_import_default_rules_into_subdirectory_on_target (${_r_out_dir}
                                                                 ${_i_target})

        verapp_copy_files_in_dir_to_subdir_on_target (${_copy_rules_target}
                                                      DIRECTORY ${_rules_in_dir}
                                                      DESTINATION ${_r_out_dir}
                                                      MATCH *.tcl
                                                      COMMENT "Vera++ rule")

        add_dependencies (${_i_target} polysquare_verapp_copy_rules)

        verapp_copy_files_in_dir_to_subdir_on_target (${_copy_profiles_target}
                                                      DIRECTORY
                                                      ${_profiles_in_dir}
                                                      DESTINATION
                                                      ${_profiles_out_dir}
                                                      COMMENT "Vera++ profile")

        add_dependencies (${_i_target} polysquare_verapp_copy_profiles)

    else (POLYSQUARE_USE_VERAPP)

        message (STATUS "vera++ style checks ${_POLYSQUARE_VERAPP_REASON}")

    endif (POLYSQUARE_USE_VERAPP)

endmacro (polysquare_vera_bootstrap)

macro (polysquare_rules_bootstrap)

    set (VERAPP_CMAKE_DIRECTORY
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/veracpp-cmake)
    set (CPPCHECK_CMAKE_DIRECTORY
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cppcheck-target-cmake)
    set (CLANG_TIDY_CMAKE_DIRECTORY
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/clang-tidy-target-cmake)
    set (IWYU_CMAKE_DIRECTORY
         ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/include-what-you-use-target-cmake)

    set (CMAKE_MODULE_PATH
         ${VERAPP_CMAKE_DIRECTORY}
         ${CPPCHECK_CMAKE_DIRECTORY}
         ${CLANG_TIDY_CMAKE_DIRECTORY}
         ${IWYU_CMAKE_DIRECTORY}
         ${CMAKE_MODULE_PATH})

    polysquare_vera_bootstrap ()
    polysquare_cppcheck_bootstrap ()
    polysquare_clang_tidy_bootstrap ()
    polysquare_include_what_you_use_bootstrap ()

endmacro (polysquare_rules_bootstrap)

function (polysquare_rules_complete_scanning)

    polysquare_cppcheck_complete_scanning ()

endfunction (polysquare_rules_complete_scanning)

macro (polysquare_gmock_bootstrap)

    option (POLYSQUARE_BUILD_TESTS "Build tests" ON)

    if (POLYSQUARE_BUILD_TESTS)

        set (GMOCK_CMAKE_DIRECTORY
             ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/gmock-cmake)

        set (CMAKE_MODULE_PATH
             ${GMOCK_CMAKE_DIRECTORY}
             ${CMAKE_MODULE_PATH})

        find_package (GoogleMock REQUIRED)

    else (POLYSQUARE_BUILD_TESTS)

        message (STATUS "Building tests has been disabled")

    endif (POLYSQUARE_BUILD_TESTS)

endmacro (polysquare_gmock_bootstrap)

set (_ALL_POLYSQUARE_CHECKS_OPTION_ARGS
     CHECK_GENERATED
     NO_CPPCHECK
     NO_UNUSED_CHECK
     NO_UNUSED_GENERATED_CHECK
     NO_VERAPP
     NO_CLANG_TIDY
     NO_IWYU
     WARN_ONLY)
set (_ALL_POLYSQUARE_CHECKS_SINGLEVAR_ARGS
     FORCE_LANGUAGE)
set (_ALL_POLYSQUARE_CHECKS_MULTIVAR_ARGS
     CLANG_TIDY_ENABLE_CHECKS
     CLANG_TIDY_DISABLE_CHECKS
     CPP_IDENTIFIERS)

set (_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS
     NO_UNITY_BUILD
     NO_PRECOMPILED_HEADERS)
set (_ALL_POLYSQUARE_ACCELERATION_MULTIVAR_ARGS
     DEPENDS)

set (_ALL_POLYSQUARE_SANITIZATION_OPTION_ARGS
     ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS}
     NO_ASAN
     NO_MSAN
     NO_TSAN
     NO_UBSAN)
set (_ALL_POLYSQUARE_SANITIZATION_MULTIVAR_ARGS
     ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS})

set (_ALL_POLYSQUARE_SOURCES_OPTION_ARGS
     ${_ALL_POLYSQUARE_CHECKS_OPTION_ARGS})
set (_ALL_POLYSQUARE_SOURCES_SINGLEVAR_ARGS
     ${_ALL_POLYSQUARE_CHECKS_SINGLEVAR_ARGS}
     UNUSED_CHECK_GROUP)
set (_ALL_POLYSQUARE_SOURCES_MULTIVAR_ARGS
     ${_ALL_POLYSQUARE_CHECKS_MULTIVAR_ARGS}
     SOURCES
     INTERNAL_INCLUDE_DIRS
     EXTERNAL_INCLUDE_DIRS
     DEFINES)

set (_ALL_POLYSQUARE_BINARY_OPTION_ARGS
     ${_ALL_POLYSQUARE_SOURCES_OPTION_ARGS}
     ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS}
     ${_ALL_POLYSQUARE_SANITIZATION_OPTION_ARGS})
set (_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS
     ${_ALL_POLYSQUARE_SOURCES_SINGLEVAR_ARGS}
     EXPORT_HEADER_DIRECTORY)
set (_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS
     ${_ALL_POLYSQUARE_SOURCES_MULTIVAR_ARGS}
     ${_ALL_POLYSQUARE_ACCELERATION_MULTIVAR_ARGS}
     LIBRARIES)

function (polysquare_add_checks_to_target TARGET)

    set (ADD_CHECKS_OPTION_ARGS
         ${_ALL_POLYSQUARE_SOURCES_OPTION_ARGS})
    set (ADD_CHECKS_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_SOURCES_SINGLEVAR_ARGS})
    set (ADD_CHECKS_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_SOURCES_MULTIVAR_ARGS})

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

    _polysquare_forward_options (CHECKS ALL_CHECKS_FORWARD_OPTIONS
                                 OPTION_ARGS WARN_ONLY CHECK_GENERATED)

    if (NOT CHECKS_NO_VERAPP AND POLYSQUARE_USE_VERAPP)

        set (_verapp_output_dir ${_POLYSQUARE_VERAPP_OUTPUT_DIRECTORY})
        set (_verapp_profile ${_POLYSQUARE_VERAPP_PROFILE})
        set (_import_rules_target ${_POLYSQUARE_VERAPP_IMPORT_RULES})

        verapp_profile_check_source_files_conformance (${_verapp_output_dir}
                                                       PROFILE ${_profile}
                                                       TARGET ${TARGET}
                                                       DEPENDS
                                                       ${_import_rules_target}
                                                       ${_verapp_check_mode}
                                                       ${ALL_CHECKS_FORWARD_OPTIONS})

    endif (NOT CHECKS_NO_VERAPP AND POLYSQUARE_USE_VERAPP)

    _polysquare_forward_options (CHECKS ANALYSIS_FORWARD_OPTIONS
                                 SINGLEVAR_ARGS FORCE_LANGUAGE
                                 MULTIVAR_ARGS
                                 DEFINES
                                 CPP_IDENTIFIERS)

    if (NOT CHECKS_NO_CPPCHECK AND POLYSQUARE_USE_CPPCHECK)

        cppcheck_target_sources (${TARGET}
                                 INCLUDES
                                 ${CHECKS_INTERNAL_INCLUDE_DIRS}
                                 ${ALL_CHECKS_FORWARD_OPTIONS}
                                 # We don't add external include dirs here
                                 ${ANALYSIS_FORWARD_OPTIONS})

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

    endif (NOT CHECKS_NO_CPPCHECK AND POLYSQUARE_USE_CPPCHECK)

    set (CHECKS_CLANG_TIDY_ENABLE_CHECKS
         ${POLYSQUARE_CLANG_TIDY_DEFAULT_ENABLED_CHECKS}
         ${CHECKS_CLANG_TIDY_ENABLE_CHECKS})
    set (CHECKS_CLANG_TIDY_DISABLE_CHECKS
         ${POLYSQUARE_CLANG_TIDY_DEFAULT_DISABLED_CHECKS}
         ${CHECKS_CLANG_TIDY_DISABLE_CHECKS})

    _polysquare_forward_options (CHECKS CLANG_CHECKS_FORWARD_OPTIONS
                                 MULTIVAR_ARGS
                                 INTERNAL_INCLUDE_DIRS
                                 EXTERNAL_INCLUDE_DIRS)

    if (NOT CHECKS_NO_CLANG_TIDY AND POLYSQUARE_USE_CLANG_TIDY)

        clang_tidy_check_target_sources (${TARGET}
                                         ${ALL_CHECKS_FORWARD_OPTIONS}
                                         ${ANALYSIS_FORWARD_OPTIONS}
                                         ${CLANG_CHECKS_FORWARD_OPTIONS}
                                         ENABLE_CHECKS
                                         ${CHECKS_CLANG_TIDY_ENABLE_CHECKS}
                                         DISABLE_CHECKS
                                         ${CHECKS_CLANG_TIDY_DISABLE_CHECKS})

    endif (NOT CHECKS_NO_CLANG_TIDY AND POLYSQUARE_USE_CLANG_TIDY)

    if (NOT CHECKS_NO_IWYU AND POLYSQUARE_USE_IWYU)

        iwyu_target_sources (${TARGET}
                             ${ALL_CHECKS_FORWARD_OPTIONS}
                             ${CLANG_CHECKS_FORWARD_OPTIONS}
                             ${ANALYSIS_FORWARD_OPTIONS})

    endif (NOT CHECKS_NO_IWYU AND POLYSQUARE_USE_IWYU)

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

function (_polysquare_forward_options PREFIX RETURN_LIST_NAME)

    set (FORWARD_OPTION_ARGS "")
    set (FORWARD_SINGLEVAR_ARGS "")
    set (FORWARD_MULTIVAR_ARGS
         OPTION_ARGS
         SINGLEVAR_ARGS
         MULTIVAR_ARGS)

    cmake_parse_arguments (FORWARD
                           "${FORWARD_OPTION_ARGS}"
                           "${FORWARD_SINGLEVAR_ARGS}"
                           "${FORWARD_MULTIVAR_ARGS}"
                           ${ARGN})

    # Temporary accumulation of variables to forward
    set (RETURN_LIST)

    # Option args - just forward the value of each set ${REFIX_OPTION_ARG}
    # as this will be set to the option or to ""
    foreach (OPTION_ARG ${FORWARD_OPTION_ARGS})

        set (PREFIXED_OPTION_ARG ${PREFIX}_${OPTION_ARG})

        if (${PREFIXED_OPTION_ARG})

             list (APPEND RETURN_LIST ${OPTION_ARG})

        endif (${PREFIXED_OPTION_ARG})

    endforeach ()

    # Single-variable args - add the name of the argument and its value to
    # the return list
    foreach (SINGLEVAR_ARG ${FORWARD_SINGLEVAR_ARGS})

        set (PREFIXED_SINGLEVAR_ARG ${PREFIX}_${SINGLEVAR_ARG})
        list (APPEND RETURN_LIST ${SINGLEVAR_ARG})
        list (APPEND RETURN_LIST ${${PREFIXED_SINGLEVAR_ARG}})

    endforeach ()

    # Multi-variable args - add the name of the argument and all its values
    # to the return-list
    foreach (MULTIVAR_ARG ${FORWARD_MULTIVAR_ARGS})

        set (PREFIXED_MULTIVAR_ARG ${PREFIX}_${MULTIVAR_ARG})
        list (APPEND RETURN_LIST ${MULTIVAR_ARG})

        foreach (VALUE ${${PREFIXED_MULTIVAR_ARG}})

            list (APPEND RETURN_LIST ${VALUE})

        endforeach ()

    endforeach ()

    set (${RETURN_LIST_NAME} ${RETURN_LIST} PARENT_SCOPE)

endfunction ()

function (polysquare_add_checked_sources TARGET)

    set (SOURCES_OPTION_ARGS
         ${_ALL_POLYSQUARE_SOURCES_OPTION_ARGS})
    set (SOURCES_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_SOURCES_SINGLEVAR_ARGS})
    set (SOURCES_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_SOURCES_MULTIVAR_ARGS})

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
                                    ${SOURCES_OPTION_ARGS})

    set (SOURCES_SCANNED_STAMP
         ${CMAKE_BINARY_DIR}/${TARGET}.stamp)

    add_custom_target (${TARGET}_scannable
                       SOURCES ${SOURCES_SOURCES})

    # Recursively invoke the build system to build the ${TARGET}_scannable
    # target. The second command will not be run if ${SOURCES_SCANNED_STAMP}
    # exists and is up to date.
    #
    # This is probably a horrible hack, however the target depdencies
    # of this custom command are unconditionally run otherwise.
    add_custom_command (OUTPUT ${SOURCES_SCANNED_STAMP}
                        COMMAND
                        ${CMAKE_COMMAND} -E touch ${SOURCES_SCANNED_STAMP}
                        COMMAND
                        ${CMAKE_COMMAND}
                        --build ${CMAKE_BINARY_DIR}
                        --target ${TARGET}_scannable
                        DEPENDS
                        ${SOURCES_SOURCES}
                        COMMENT "Checking source group: ${TARGET}"
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

    add_custom_target (${TARGET} ALL
                       DEPENDS ${SOURCES_SCANNED_STAMP})

    set_property (SOURCE ${SOURCES_SCANNED_STAMP}
                  PROPERTY OBJECT_DEPENDS
                  ${SOURCES_SOURCES})

    _polysquare_forward_options (SOURCES FORWARD_OPTIONS
                                 OPTION_ARGS ${SOURCES_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${SOURCES_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${SOURCES_MULTIVAR_ARGS})

    polysquare_add_checks_to_target (${TARGET}_scannable
                                     ${FORWARD_OPTIONS})

endfunction (polysquare_add_checked_sources)

function (polysquare_accelerate_target_compilation TARGET)

    if (NOT COMMAND psq_accelerate_target)

        return ()

    endif (NOT COMMAND psq_accelerate_target)

    set (ACCELERATE_OPTION_ARGS
         ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS})
    set (ACCELERATE_SINGLEVAR_ARGS
         "")
    set (ACCELERATE_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_ACCELERATION_MULTIVAR_ARGS})

    cmake_parse_arguments (ACCELERATION
                           "${ACCELERATE_OPTION_ARGS}"
                           "${ACCELERATE_SINGLEVAR_ARGS}"
                           "${ACCELERATE_MULTIVAR_ARGS}"
                           ${ARGN})

    # Set ACCELERATION_NO_UNITY_BUILD and ACCELERATION_NO_PRECOMPILED_HEADERS
    # from POLYSQUARE_GENERATE_* options
    if (NOT POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

        set (ACCELERATION_NO_UNITY_BUILD ON)

    endif (NOT POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

    if (NOT POLYSQUARE_USE_PRECOMPILED_HEADERS)

        set (ACCELERATION_NO_PRECOMPILED_HEADERS ON)

    endif (NOT POLYSQUARE_USE_PRECOMPILED_HEADERS)

    _polysquare_forward_options (ACCELERATION ACCELERATE_TARGET_FORWARD_OPTS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS}
                                 MULTIVAR_ARGS DEPENDS)
    psq_accelerate_target (${TARGET}
                           ${ACCELERATE_TARGET_FORWARD_OPTS})

endfunction (polysquare_accelerate_target_compilation)

function (polysquare_add_sanitization_to_target TARGET)

    if (NOT COMMAND sanitizer_add_sanitization_to_target)

        return ()

    endif (NOT COMMAND sanitizer_add_sanitization_to_target)

    set (SANITIZATION_OPTION_ARGS
         ${_ALL_POLYSQUARE_SANITIZATION_OPTION_ARGS})
    set (SANITIZATION_MULTIVAR_ARGS
         DEPENDS)

    cmake_parse_arguments (SANITIZATION
                           "${SANITIZATION_OPTION_ARGS}"
                           ""
                           "${SANITIZATION_MULTIVAR_ARGS}"
                           ${ARGN})

    _polysquare_forward_options (SANITIZATION SANITIZER_FORWARD_OPTIONS
                                 OPTION_ARGS ${SANITIZATION_OPTION_ARGS}
                                 MULTIVAR_ARGS ${SANITIZATION_MULTIVAR_ARGS})

    # Accelerate the sanitized target too
    sanitizer_add_sanitization_to_target (${TARGET}
                                          ${SANITIZER_FORWARD_OPTIONS})
    _polysquare_forward_options (TARGET ACCELERATE_FWD_OPTS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS}
                                 MULTIVAR_ARGS
                                 ${_ALL_POLYSQUARE_ACCELERATION_MULTIVAR_ARGS})

    # Search for any targets ending in asan, msan, tsan and ubsan
    set (SANITIZERS_SUFFIXES asan msan tsan ubsan)

    foreach (SUFFIX ${SANITIZERS_SUFFIXES})

        if (TARGET ${TARGET}_${SUFFIX})

            polysquare_accelerate_target_compilation (${TARGET}_${SUFFIX}
                                                      ${ACCELERATE_FWD_OPTS})

        endif (TARGET ${TARGET}_${SUFFIX})

    endforeach ()

endfunction (polysquare_add_sanitization_to_target)

function (_polysquare_add_target_internal TARGET)

    set (TARGET_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (TARGET_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (TARGET_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (TARGET
                           "${TARGET_OPTION_ARGS}"
                           "${TARGET_SINGLEVAR_ARGS}"
                           "${TARGET_MULTIVAR_ARGS}"
                           ${ARGN})

    if (TARGET_LIBRARIES)

        target_link_libraries (${TARGET}
                               ${TARGET_LIBRARIES})

    endif (TARGET_LIBRARIES)

    if (TARGET_DEPENDS)

        add_dependencies (${TARGET} ${TARGET_DEPENDS})

    endif (TARGET_DEPENDS)

    if (TARGET_INTERNAL_INCLUDE_DIRS OR TARGET_EXTERNAL_INCLUDE_DIRS)

        # On older versions of CMake we need to use the directory-level
        # include_directories command
        if (CMAKE_VERSION VERSION_LESS 2.8.12)

            include_directories (SYSTEM ${TARGET_EXTERNAL_INCLUDE_DIRS})
            include_directories (${TARGET_INTERNAL_INCLUDE_DIRS})

        else (CMAKE_VERSION VERSION_LESS 2.8.12)

            if (TARGET_INTERNAL_INCLUDE_DIRS)

                set_property (TARGET ${TARGET}
                              APPEND PROPERTY INCLUDE_DIRECTORIES
                              ${TARGET_INTERNAL_INCLUDE_DIRS})

            endif (TARGET_INTERNAL_INCLUDE_DIRS)

            if (TARGET_EXTERNAL_INCLUDE_DIRS)

                # Apparently they also need to be added to the directory
                # scope as well, though it is still useful to have them
                # be part of the interface
                include_directories (SYSTEM ${TARGET_EXTERNAL_INCLUDE_DIRS})

                # Only EXTERNAL_INCLUDE_DIRS make up part of the
                # target's INTERFACE for now
                set_property (TARGET ${TARGET}
                              APPEND PROPERTY
                              INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
                              ${TARGET_EXTERNAL_INCLUDE_DIRS})

            endif (TARGET_EXTERNAL_INCLUDE_DIRS)

        endif (CMAKE_VERSION VERSION_LESS 2.8.12)

        # XCode won't mark system include dirs with -isystem, so append
        # -isystem ${EXTERNAL_INCLUDE_DIR} to the target's COMPILE_FLAGS for
        # now
        if (XCODE)

            foreach (EXTERNAL_INCLUDE_DIR ${TARGET_EXTERNAL_INCLUDE_DIRS})

                set_property (TARGET ${TARGET}
                              APPEND_STRING PROPERTY COMPILE_FLAGS
                              " -isystem ${EXTERNAL_INCLUDE_DIR}")

            endforeach ()

        endif (XCODE)

    endif (TARGET_INTERNAL_INCLUDE_DIRS OR TARGET_EXTERNAL_INCLUDE_DIRS)

    foreach (DEFINE ${TARGET_DEFINES})

        add_definitions (-D${DEFINE})

    endforeach ()

    if (TARGET_EXPORT_HEADER_DIRECTORY)

        set_property (TARGET ${TARGET}
                      PROPERTY EXPORT_HEADER_DIRECTORY
                      ${TARGET_EXPORT_HEADER_DIRECTORY})

    endif (TARGET_EXPORT_HEADER_DIRECTORY)

    _clear_variable_names_if_false (TARGET
                                    ${TARGET_OPTION_ARGS})

    _polysquare_forward_options (TARGET SANITIZATION_FORWARD_OPTIONS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_SANITIZATION_OPTION_ARGS}
                                 MULTIVAR_ARGS
                                 ${_ALL_POLYSQUARE_SANITIZATION_MULTIVAR_ARGS})
    polysquare_add_sanitization_to_target (${TARGET}
                                           ${SANITIZATION_FORWARD_OPTIONS})

    _polysquare_forward_options (TARGET ACCELERATE_FORWARD_OPTIONS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_ACCELERATION_OPTION_ARGS}
                                 MULTIVAR_ARGS
                                 ${_ALL_POLYSQUARE_ACCELERATION_MULTIVAR_ARGS})
    polysquare_accelerate_target_compilation (${TARGET}
                                              ${ACCELERATE_FORWARD_OPTIONS})

    # Make sure that we add checks to a target AFTER the target has been
    # accelerated. This enables us to add target_pch as a dependency
    # (which is necessary since the precompiled header file is not a
    #  source of the target and the rule will need to be run before
    #  any checks run)
    set (ADDITIONAL_CHECKS_DEPENDENCIES)
    if (TARGET ${TARGET}_pch)

        set (ADDITIONAL_CHECKS_DEPENDENCIES ${TARGET}_pch)

    endif (TARGET ${TARGET}_pch)

    _polysquare_forward_options (TARGET CHECKS_FORWARD_OPTIONS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_CHECKS_OPTION_ARGS}
                                 SINGLEVAR_ARGS
                                 ${_ALL_POLYSQUARE_SOURCES_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS
                                 ${_ALL_POLYSQUARE_SOURCES_MULTIVAR_ARGS})
    polysquare_add_checks_to_target (${TARGET}
                                     ${CHECKS_FORWARD_OPTIONS}
                                     DEPENDS
                                     ${ADDITIONAL_CHECKS_DEPENDENCIES}
                                     ${CHECKS_DEPENDENCIES})

endfunction (_polysquare_add_target_internal)

function (polysquare_add_library LIBRARY_NAME LIBRARY_TYPE)

    set (LIBRARY_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (LIBRARY_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (LIBRARY_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

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
                                    ${LIBRARY_OPTION_ARGS})

    _polysquare_forward_options (LIBRARY FORWARD_OPTIONS
                                 OPTION_ARGS ${LIBRARY_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${LIBRARY_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${LIBRARY_MULTIVAR_ARGS})

    _polysquare_add_target_internal (${LIBRARY_NAME}
                                     ${FORWARD_OPTIONS})

endfunction (polysquare_add_library)

function (polysquare_add_executable EXECUTABLE_NAME)

    set (EXECUTABLE_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (EXECUTABLE_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (EXECUTABLE_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

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
                                    ${EXECUTABLE_OPTION_ARGS})
    _polysquare_forward_options (EXECUTABLE FORWARD_OPTIONS
                                 OPTION_ARGS ${EXECUTABLE_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${EXECUTABLE_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${EXECUTABLE_MULTIVAR_ARGS})

    _polysquare_add_target_internal (${EXECUTABLE_NAME}
                                     ${FORWARD_OPTIONS})

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
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (TEST_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS}
         MAIN_LIBRARY)
    set (TEST_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS}
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
                                    ${TEST_OPTION_ARGS})
    _polysquare_forward_options (TEST FORWARD_OPTIONS
                                 OPTION_ARGS
                                 ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS}
                                 SINGLEVAR_ARGS
                                 ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS
                                 ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

    polysquare_add_executable (${TEST_NAME}
                               ${FORWARD_OPTIONS})

endfunction (polysquare_add_test)

function (polysquare_add_test_main MAIN_LIBRARY_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MAIN_LIBRARY_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (MAIN_LIBRARY_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (MAIN_LIBRARY_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

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

    # Make sure to expand MAIN_LIB_EXT_INC_DIRS for _polysquare_forward_options
    set (MAIN_LIBRARY_EXTERNAL_INCLUDE_DIRS ${MAIN_LIB_EXT_INC_DIRS})

    _clear_variable_names_if_false (MAIN_LIBRARY
                                    ${MAIN_LIBRARY_OPTION_ARGS})

    _polysquare_forward_options (MAIN_LIBRARY FORWARD_OPTIONS
                                 OPTION_ARGS ${MAIN_LIBRARY_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${MAIN_LIBRARY_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${MAIN_LIBRARY_MULTIVAR_ARGS})

    polysquare_add_library (${MAIN_LIBRARY_NAME} STATIC
                            ${FORWARD_OPTIONS})

endfunction (polysquare_add_test_main)

function (polysquare_add_matcher MATCHER_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MATCHER_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (MATCHER_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (MATCHER_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

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
                                    ${MATCHER_OPTION_ARGS})

    _polysquare_forward_options (MATCHER FORWARD_OPTIONS
                                 OPTION_ARGS ${MATCHER_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${MATCHER_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${MATCHER_MULTIVAR_ARGS})

    polysquare_add_library (${MATCHER_NAME} STATIC
                            ${FORWARD_OPTIONS})

endfunction (polysquare_add_matcher)

function (polysquare_add_mock MOCK_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif (NOT POLYSQUARE_BUILD_TESTS)

    set (MOCK_OPTION_ARGS
         ${_ALL_POLYSQUARE_BINARY_OPTION_ARGS})
    set (MOCK_SINGLEVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_SINGLEVAR_ARGS})
    set (MOCK_MULTIVAR_ARGS
         ${_ALL_POLYSQUARE_BINARY_MULTIVAR_ARGS})

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
                                    ${MOCK_OPTION_ARGS})

    _polysquare_forward_options (MOCK FORWARD_OPTIONS
                                 OPTION_ARGS ${MOCK_OPTION_ARGS}
                                 SINGLEVAR_ARGS ${MOCK_SINGLEVAR_ARGS}
                                 MULTIVAR_ARGS ${MOCK_MULTIVAR_ARGS})

    polysquare_add_library (${MOCK_NAME} STATIC
                            ${FORWARD_OPTIONS})

endfunction (polysquare_add_mock)
