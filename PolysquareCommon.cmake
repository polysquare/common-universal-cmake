# /PolysquareCommon.cmake
#
# Provides some functionality that is common to all polysquare projects,
# such as bootstrapping static analysis tools, adding code coverage
# targets and convenience functions to add tests, matchers, mocks etc
# without having to write too much boilerplate.
#
# See /LICENCE.md for Copyright information

include ("cmake/cmake-include-guard/IncludeGuard")
cmake_include_guard (SET_MODULE_PATH)

include ("cmake/cmake-forward-arguments/ForwardArguments")
include (CMakeParseArguments)
include (CheckCXXCompilerFlag)
include (GenerateExportHeader)

# This file's directory
set (PSQ_COMMON_UNIVERSAL_CMAKE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")

function (_psq_add_cxx_flag FLAG_VARIABLE CXXFLAGS_VARIABLE)

    check_cxx_compiler_flag ("${${FLAG_VARIABLE}}" HAVE_${FLAG_VARIABLE})
    if (HAVE_${FLAG_VARIABLE})

        set (${CXXFLAGS_VARIABLE}
             "${${CXXFLAGS_VARIABLE}} ${${FLAG_VARIABLE}}"
             PARENT_SCOPE)

    endif ()

endfunction ()

function (psq_compiler_bootstrap)

    cmake_parse_arguments (PSQ_COMPILER
                           ""
                           "STANDARD"
                           ""
                           ${ARGN})

    if (PSQ_COMPILER_STANDARD STREQUAL "")

        set (PSQ_COMPILER_STANDARD "c++1y")

    endif ()

    option (POLYSQUARE_USE_STRICT_COMPILER "Make compiler warnings errors" ON)

    set (PSQ_WERROR)

    # -Werror only mandatory if the user asked for it
    if (POLYSQUARE_USE_STRICT_COMPILER)

        set (PSQ_WERROR "-Werror")
        set (PSQ_WX "/WX")

    endif ()

    set (PSQ_CXX11 "-std=${PSQ_COMPILER_STANDARD}")
    set (PSQ_WALL "-Wall")
    set (PSQ_WFOUR "/W4")
    set (PSQ_WEXTRA "-Wextra")
    set (PSQ_WNO_UNUSED_PARAMETER "-Wno-unused-parameter")
    set (PSQ_FPIC "-fPIC")

    # -fPIC and -Wall -Wextra are mandatory on compilers that
    # support them.
    _psq_add_cxx_flag (PSQ_CXX11 PSQ_CXXFLAGS)
    _psq_add_cxx_flag (PSQ_WALL PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_WEXTRA PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_WNO_UNUSED_PARAMETER PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_WERROR PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_WX PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_WFOUR PSQ_CFLAGS)
    _psq_add_cxx_flag (PSQ_FPIC PSQ_CFLAGS)

    set (CMAKE_CXX_STANDARD_REQUIRED 14 PARENT_SCOPE)

    set_property (GLOBAL PROPERTY PSQ_CFLAGS "${PSQ_CFLAGS}")
    set_property (GLOBAL PROPERTY PSQ_CXXFLAGS "${PSQ_CXXFLAGS}")

    # Generate a compilation commands database
    set (CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

endfunction ()

macro (psq_sanitizers_bootstrap)

    include ("cmake/sanitize-target-cmake/SanitizeTarget")

endmacro ()

macro (psq_acceleration_bootstrap)

    option (POLYSQUARE_USE_PRECOMPILED_HEADERS
            "Generate precompiled headers for targets where appropriate"
            ON)
    option (POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS
            "Generate single-source-file targets, invoked with target_unity"
            ON)

    if (POLYSQUARE_USE_PRECOMPILED_HEADERS OR
        POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

        include ("cmake/accelerate-target-cmake/AccelerateTarget")

    endif (POLYSQUARE_USE_PRECOMPILED_HEADERS OR
           POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

endmacro ()

macro (psq_coverage_bootstrap)

    include ("cmake/gcov-cmake/GCovUtilities")
    gcov_get_compile_flags (PSQ_CB_CFLAGS PSQ_CB_LDFLAGS)

    get_property (PSQ_CB_PSQ_CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
    set_property (GLOBAL PROPERTY PSQ_CFLAGS
                  "${PSQ_CB_PSQ_CFLAGS} ${PSQ_CB_CFLAGS}")

    get_property (PSQ_CB_PSQ_LDFLAGS GLOBAL PROPERTY PSQ_LDFLAGS)
    set_property (GLOBAL PROPERTY PSQ_LDFLAGS
                  "${PSQ_CB_PSQ_LDFLAGS} ${PSQ_CB_LDFLAGS}")

endmacro ()

macro (psq_cppcheck_bootstrap)

    option (POLYSQUARE_USE_CPPCHECK
            "Perform simple static analysis for known bad practices"
            ON)

    if (POLYSQUARE_USE_CPPCHECK)

        include ("cmake/cppcheck-target-cmake/CPPCheck")

        cppcheck_validate (CPPCHECK_AVAILABLE)

        if (NOT CPPCHECK_AVAILABLE)

            set (_POLYSQUARE_CPPCHECK_REASON "is unavailable")
            set (POLYSQUARE_USE_CPPCHECK OFF)

        endif ()

    else ()

        set (_POLYSQUARE_CPPCHECK_REASON "has been disabled")

    endif ()

    if (NOT POLYSQUARE_USE_CPPCHECK)

        message (STATUS "cppcheck analysis ${_POLYSQUARE_CPPCHECK_REASON}")

    endif ()

endmacro ()

function (psq_cppcheck_complete_scanning)

    if (NOT POLYSQUARE_USE_CPPCHECK)

        return ()

    endif ()

    cppcheck_get_unused_function_checks (UNUSED_CHECKS)

    foreach (CHECK ${UNUSED_CHECKS})

        cppcheck_add_unused_function_check_with_name (${CHECK})

    endforeach ()

endfunction ()

macro (psq_clang_tidy_bootstrap)

    option (POLYSQUARE_USE_CLANG_TIDY
            "Perform simple static analysis using clang"
            ON)

    if (POLYSQUARE_USE_CLANG_TIDY)

        include ("cmake/clang-tidy-target-cmake/ClangTidy")

        clang_tidy_validate (CLANG_TIDY_AVAILABLE)

        if (CLANG_TIDY_AVAILABLE)

            # These are used later in psq_add_checks_to_target
            set (PSQ_CLANG_TIDY_DEFAULT_ON_CHECKS) # NOLINT:unused/var_in_func
            set (PSQ_CLANG_TIDY_DEFAULT_OFF_CHECKS # NOLINT:unused/var_in_func
                 "llvm-*"
                 "google-*")

        else ()

            set (_POLYSQUARE_CLANG_TIDY_REASON "is unavailable")
            set (POLYSQUARE_USE_CLANG_TIDY OFF)

        endif ()

    else ()

        set (_POLYSQUARE_CLANG_TIDY_REASON "has been disabled")

    endif ()

    if (NOT POLYSQUARE_USE_CLANG_TIDY)

        message (STATUS "clang-tidy analysis ${_POLYSQUARE_CLANG_TIDY_REASON}.")

    endif ()

endmacro ()

macro (psq_include_what_you_use_bootstrap)

    option (POLYSQUARE_USE_IWYU
            "Perform checks to ensure that there are no unecessary #includes"
            ON)

    if (POLYSQUARE_USE_IWYU)

        include ("cmake/iwyu-target-cmake/IncludeWhatYouUse")

        iwyu_validate (IWYU_AVAILABLE)

        if (NOT IWYU_AVAILABLE)

            set (_POLYSQUARE_IWYU_REASON "is unavailable")
            set (POLYSQUARE_USE_IWYU OFF)

        endif ()

    else ()

        set (_POLYSQUARE_IWYU_REASON "has been disabled")

    endif ()

    if (NOT POLYSQUARE_USE_IWYU)

        message (STATUS "include-what-you-use analysis"
                        " ${_POLYSQUARE_IWYU_REASON}.")

    endif ()

endmacro ()

macro (psq_vera_bootstrap)

    option (POLYSQUARE_USE_VERAPP
            "Check source files for style compliance with vera++"
            ON)

    if (POLYSQUARE_USE_VERAPP)

        include ("cmake/verapp-cmake/VeraPPUtilities")
        verapp_validate (VERAPP_AVAILABLE 1.2)

        if (NOT VERAPP_AVAILABLE)

            set (PSQ_VERAPP_REASON "are unavailable")
            set (POLYSQUARE_USE_VERAPP OFF)

        endif ()

    else ()

        set (PSQ_VERAPP_REASON "have been disabled")

    endif ()

    if (POLYSQUARE_USE_VERAPP)

        set (PSQ_VERAPP_OUTPUT_DIRECTORY
             "${CMAKE_CURRENT_BINARY_DIR}/vera++")
        set (PSQ_VERAPP_SCRIPTS_OUTPUT_DIRECTORY
             "${PSQ_VERAPP_OUTPUT_DIRECTORY}/scripts")
        set (PSQ_VERAPP_SOURCE_DIRECTORY
             "${PSQ_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/vera++")
        set (PSQ_VERAPP_SCRIPTS_SOURCE_DIRECTORY
             "${PSQ_VERAPP_SOURCE_DIRECTORY}/scripts")
        set (PSQ_VERAPP_PROFILE polysquare)  # NOLINT:unused/var_in_func
        set (PSQ_VERAPP_IMPORT_RULES psq_verapp_import_rules)

        set (_I_TARGET ${PSQ_VERAPP_IMPORT_RULES})
        set (_COPY_RULES_TARGET psq_verapp_copy_rules)
        set (_COPY_PROFILES_TARGET psq_verapp_copy_profiles)
        set (_R_OUT_DIR
             "${PSQ_VERAPP_SCRIPTS_OUTPUT_DIRECTORY}/rules")
        set (_PROFILES_OUT_DIR
             "${PSQ_VERAPP_OUTPUT_DIRECTORY}/profiles")
        set (_RULES_IN_DIR
             "${PSQ_VERAPP_SCRIPTS_SOURCE_DIRECTORY}/rules")
        set (_PROFILES_IN_DIR
             "${PSQ_VERAPP_SOURCE_DIRECTORY}/profiles")

        add_custom_target (${_I_TARGET} ALL)

        verapp_import_default_rules_into_subdir_on_target ("${_R_OUT_DIR}"
                                                           ${_I_TARGET})

        verapp_copy_files_in_dir_to_subdir_on_target (${_COPY_RULES_TARGET}
                                                      DIRECTORY
                                                      "${_RULES_IN_DIR}"
                                                      DESTINATION
                                                      "${_R_OUT_DIR}"
                                                      MATCH *.tcl
                                                      COMMENT "Vera++ rule")

        add_dependencies (${_I_TARGET} psq_verapp_copy_rules)

        verapp_copy_files_in_dir_to_subdir_on_target (${_COPY_PROFILES_TARGET}
                                                      DIRECTORY
                                                      "${_PROFILES_IN_DIR}"
                                                      DESTINATION
                                                      "${_PROFILES_OUT_DIR}"
                                                      COMMENT "Vera++ profile")

        add_dependencies (${_I_TARGET} psq_verapp_copy_profiles)

    else ()

        message (STATUS "vera++ style checks ${PSQ_VERAPP_REASON}")

    endif ()

endmacro ()

macro (psq_rules_bootstrap)

    psq_vera_bootstrap ()
    psq_cppcheck_bootstrap ()
    psq_clang_tidy_bootstrap ()
    psq_include_what_you_use_bootstrap ()

endmacro ()

function (psq_rules_complete_scanning)

    psq_cppcheck_complete_scanning ()

endfunction ()

macro (psq_gmock_bootstrap)

    option (POLYSQUARE_BUILD_TESTS "Build tests" ON)

    if (POLYSQUARE_BUILD_TESTS)

        include ("cmake/gmock-cmake/GMockImport")
        gmock_import_from_find_module (REQUIRED)

    else ()

        message (STATUS "Building tests has been disabled")

    endif ()

endmacro ()

set (PSQ_ALL_CHECKS_OPTION_ARGS
     CHECK_GENERATED
     NO_CPPCHECK
     NO_UNUSED_CHECK
     NO_UNUSED_GENERATED_CHECK
     NO_VERAPP
     NO_CLANG_TIDY
     NO_IWYU
     WARN_ONLY)
set (PSQ_ALL_CHECKS_SINGLEVAR_ARGS
     FORCE_LANGUAGE)
set (PSQ_ALL_CHECKS_MULTIVAR_ARGS
     CLANG_TIDY_ENABLE_CHECKS
     CLANG_TIDY_DISABLE_CHECKS
     CPP_IDENTIFIERS)

set (PSQ_ALL_ACCELERATION_OPTION_ARGS
     NO_UNITY_BUILD
     NO_PRECOMPILED_HEADERS)
set (PSQ_ALL_ACCELERATION_MULTIVAR_ARGS
     DEPENDS)

set (PSQ_ALL_SANITIZATION_OPTION_ARGS
     NO_ASAN
     NO_MSAN
     NO_TSAN
     NO_UBSAN)
set (PSQ_ALL_SANITIZATION_MULTIVAR_ARGS
     DEPENDS)

set (PSQ_ALL_SOURCES_OPTION_ARGS
     ${PSQ_ALL_CHECKS_OPTION_ARGS})
set (PSQ_ALL_SOURCES_SINGLEVAR_ARGS
     ${PSQ_ALL_CHECKS_SINGLEVAR_ARGS}
     UNUSED_CHECK_GROUP)
set (PSQ_ALL_SOURCES_MULTIVAR_ARGS
     ${PSQ_ALL_CHECKS_MULTIVAR_ARGS}
     SOURCES
     INTERNAL_INCLUDE_DIRS
     EXTERNAL_INCLUDE_DIRS
     DEFINES)

set (PSQ_ALL_BINARY_OPTION_ARGS
     ${PSQ_ALL_SOURCES_OPTION_ARGS}
     ${PSQ_ALL_ACCELERATION_OPTION_ARGS}
     ${PSQ_ALL_SANITIZATION_OPTION_ARGS})
set (PSQ_ALL_BINARY_SINGLEVAR_ARGS
     ${PSQ_ALL_SOURCES_SINGLEVAR_ARGS}
     EXPORT_HEADER_DIRECTORY)
set (PSQ_ALL_BINARY_MULTIVAR_ARGS
     ${PSQ_ALL_SOURCES_MULTIVAR_ARGS}
     ${PSQ_ALL_ACCELERATION_MULTIVAR_ARGS}
     LIBRARIES
     LINK_DIRECTORIES)

function (psq_add_checks_to_target TARGET)

    set (ADD_CHECKS_OPTION_ARGS
         ${PSQ_ALL_SOURCES_OPTION_ARGS})
    set (ADD_CHECKS_SINGLEVAR_ARGS
         ${PSQ_ALL_SOURCES_SINGLEVAR_ARGS})
    set (ADD_CHECKS_MULTIVAR_ARGS
         ${PSQ_ALL_SOURCES_MULTIVAR_ARGS})

    cmake_parse_arguments (CHECKS
                           "${ADD_CHECKS_OPTION_ARGS}"
                           "${ADD_CHECKS_SINGLEVAR_ARGS}"
                           "${ADD_CHECKS_MULTIVAR_ARGS}"
                           ${ARGN})

    if (CHECKS_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${CHECKS_UNPARSED_ARUGMENTS} "
                 "given to psq_add_checks_to_target")

    endif ()

    cmake_forward_arguments (CHECKS ALL_CHECKS_FWD_OPTS
                             OPTION_ARGS WARN_ONLY CHECK_GENERATED)

    if (NOT CHECKS_NO_VERAPP AND POLYSQUARE_USE_VERAPP)

        set (_VERAPP_OUTPUT_DIR "${PSQ_VERAPP_OUTPUT_DIRECTORY}")
        set (_VERAPP_PROFILE "${PSQ_VERAPP_PROFILE}")
        set (_IMPORT_RULES_TARGET ${PSQ_VERAPP_IMPORT_RULES})

        verapp_profile_check_source_files_conformance ("${_VERAPP_OUTPUT_DIR}"
                                                       PROFILE
                                                       "${_VERAPP_PROFILE}"
                                                       TARGET ${TARGET}
                                                       DEPENDS
                                                       ${_IMPORT_RULES_TARGET}
                                                       ${ALL_CHECKS_FWD_OPTS})

    endif ()

    cmake_forward_arguments (CHECKS ANALYSIS_FORWARD_OPTIONS
                             SINGLEVAR_ARGS FORCE_LANGUAGE
                             MULTIVAR_ARGS
                             DEFINES
                             CPP_IDENTIFIERS)

    if (NOT CHECKS_NO_CPPCHECK AND POLYSQUARE_USE_CPPCHECK)

        cppcheck_target_sources (${TARGET}
                                 INCLUDES
                                 ${CHECKS_INTERNAL_INCLUDE_DIRS}
                                 ${ALL_CHECKS_FWD_OPTS}
                                 # We don't add external include dirs here
                                 ${ANALYSIS_FORWARD_OPTIONS}
                                 NO_CHECK_UNUSED)

        if (NOT CHECKS_NO_UNUSED_CHECK)

            # CHECK_GENERATED is on by default unless explicitly disabled.
            set (CHECK_GENERATED_UNUSED_OPTION CHECK_GENERATED)
            if (CHECKS_NO_UNUSED_GENERATED_CHECK)

                set (CHECK_GENERATED_UNUSED_OPTION)

            endif ()

            set (CHECK_NAME psq_check_all_unused)
            if (CHECKS_UNUSED_CHECK_GROUP)

                set (CHECK_NAME ${CHECKS_UNUSED_CHECK_GROUP})

            endif ()

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

        endif ()

    endif ()

    set (CHECKS_CLANG_TIDY_ENABLE_CHECKS
         ${PSQ_CLANG_TIDY_DEFAULT_ON_CHECKS}
         ${CHECKS_CLANG_TIDY_ENABLE_CHECKS})
    set (CHECKS_CLANG_TIDY_DISABLE_CHECKS
         ${PSQ_CLANG_TIDY_DEFAULT_OFF_CHECKS}
         ${CHECKS_CLANG_TIDY_DISABLE_CHECKS})

    cmake_forward_arguments (CHECKS CLANG_CHECKS_FORWARD_OPTIONS
                             MULTIVAR_ARGS
                             INTERNAL_INCLUDE_DIRS
                             EXTERNAL_INCLUDE_DIRS)

    if (NOT CHECKS_NO_CLANG_TIDY AND POLYSQUARE_USE_CLANG_TIDY)

        clang_tidy_check_target_sources (${TARGET}
                                         ${ALL_CHECKS_FWD_OPTS}
                                         ${ANALYSIS_FORWARD_OPTIONS}
                                         ${CLANG_CHECKS_FORWARD_OPTIONS}
                                         ENABLE_CHECKS
                                         ${CHECKS_CLANG_TIDY_ENABLE_CHECKS}
                                         DISABLE_CHECKS
                                         ${CHECKS_CLANG_TIDY_DISABLE_CHECKS})

    endif ()

    if (NOT CHECKS_NO_IWYU AND POLYSQUARE_USE_IWYU)

        iwyu_target_sources (${TARGET}
                             ${ALL_CHECKS_FWD_OPTS}
                             ${CLANG_CHECKS_FORWARD_OPTIONS}
                             ${ANALYSIS_FORWARD_OPTIONS})

    endif ()

endfunction ()

function (_psq_clear_variable_names_if_false PREFIX)

    foreach (VAR_NAME ${ARGN})

        set (PREFIX_VAR_NAME ${PREFIX}_${VAR_NAME})

        if (NOT ${PREFIX_VAR_NAME})

            set (${PREFIX_VAR_NAME} PARENT_SCOPE)

        else ()

            set (${PREFIX_VAR_NAME} ${VAR_NAME} PARENT_SCOPE)

        endif ()

    endforeach ()

endfunction ()

function (psq_add_checked_sources TARGET)

    set (SOURCES_OPTION_ARGS
         ${PSQ_ALL_SOURCES_OPTION_ARGS})
    set (SOURCES_SINGLEVAR_ARGS
         ${PSQ_ALL_SOURCES_SINGLEVAR_ARGS})
    set (SOURCES_MULTIVAR_ARGS
         ${PSQ_ALL_SOURCES_MULTIVAR_ARGS})

    cmake_parse_arguments (SOURCES
                           "${SOURCES_OPTION_ARGS}"
                           "${SOURCES_SINGLEVAR_ARGS}"
                           "${SOURCES_MULTIVAR_ARGS}"
                           ${ARGN})

    if (SOURCES_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${SOURCES_UNPARSED_ARUGMENTS} "
                 "given to psq_add_checked_sources")

    endif ()

    _psq_clear_variable_names_if_false (SOURCES
                                        ${SOURCES_OPTION_ARGS})

    set (SOURCES_SCANNED_STAMP
         "${CMAKE_BINARY_DIR}/${TARGET}.stamp")

    add_custom_target (${TARGET}_scannable
                       SOURCES ${SOURCES_SOURCES})

    # Recursively invoke the build system to build the ${TARGET}_scannable
    # target. The second command will not be run if ${SOURCES_SCANNED_STAMP}
    # exists and is up to date.
    #
    # This is probably a horrible hack, however the target dependencies
    # of this custom command are unconditionally run otherwise.
    add_custom_command (OUTPUT ${SOURCES_SCANNED_STAMP}
                        COMMAND
                        "${CMAKE_COMMAND}"
                        -E
                        touch
                        "${SOURCES_SCANNED_STAMP}"
                        COMMAND
                        "${CMAKE_COMMAND}"
                        --build
                        "${CMAKE_BINARY_DIR}"
                        --target
                        ${TARGET}_scannable
                        DEPENDS
                        ${SOURCES_SOURCES}
                        COMMENT "Checking source group: ${TARGET}"
                        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")

    add_custom_target (${TARGET} ALL
                       DEPENDS ${SOURCES_SCANNED_STAMP})

    get_property (PSQ_CXXFLAGS GLOBAL PROPERTY PSQ_CXXFLAGS)
    get_property (PSQ_CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
    set_property (TARGET ${TARGET}_scannable
                  PROPERTY COMPILE_FLAGS
                  "${PSQ_CFLAGS} ${PSQ_CXXFLAGS}")
    get_property (COMPILE_FLAGS
                  TARGET "${TARGET}_scannable"
                  PROPERTY COMPILE_FLAGS)

    set_property (SOURCE ${SOURCES_SCANNED_STAMP}
                  PROPERTY OBJECT_DEPENDS
                  ${SOURCES_SOURCES})

    cmake_forward_arguments (SOURCES FORWARD_OPTIONS
                             OPTION_ARGS ${SOURCES_OPTION_ARGS}
                             SINGLEVAR_ARGS ${SOURCES_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${SOURCES_MULTIVAR_ARGS})

    psq_add_checks_to_target (${TARGET}_scannable
                              ${FORWARD_OPTIONS})

endfunction ()

function (psq_accelerate_target_compilation TARGET)

    if (NOT COMMAND psq_accelerate_target)

        return ()

    endif ()

    set (ACCELERATE_OPTION_ARGS
         ${PSQ_ALL_ACCELERATION_OPTION_ARGS})
    set (ACCELERATE_SINGLEVAR_ARGS
         "")
    set (ACCELERATE_MULTIVAR_ARGS
         ${PSQ_ALL_ACCELERATION_MULTIVAR_ARGS})

    cmake_parse_arguments (ACCELERATION
                           "${ACCELERATE_OPTION_ARGS}"
                           "${ACCELERATE_SINGLEVAR_ARGS}"
                           "${ACCELERATE_MULTIVAR_ARGS}"
                           ${ARGN})

    # Set ACCELERATION_NO_UNITY_BUILD and ACCELERATION_NO_PRECOMPILED_HEADERS
    # from POLYSQUARE_GENERATE_* options
    if (NOT POLYSQUARE_GENERATE_UNITY_BUILD_TARGETS)

        set (ACCELERATION_NO_UNITY_BUILD ON) # NOLINT:unused/var_in_func

    endif ()

    if (NOT POLYSQUARE_USE_PRECOMPILED_HEADERS)

        set (ACCELERATION_NO_PRECOMPILED_HEADERS ON) # NOLINT:unused/var_in_func

    endif ()

    cmake_forward_arguments (ACCELERATION ACCELERATE_TARGET_FORWARD_OPTS
                             OPTION_ARGS
                             ${PSQ_ALL_ACCELERATION_OPTION_ARGS}
                             MULTIVAR_ARGS DEPENDS)
    psq_accelerate_target (${TARGET}
                           ${ACCELERATE_TARGET_FORWARD_OPTS})

endfunction ()

function (psq_add_sanitization_to_target TARGET)

    if (NOT COMMAND psq_sanitizer_add_sanitization_to_target)

        return ()

    endif ()

    set (SANITIZATION_OPTION_ARGS
         ${PSQ_ALL_SANITIZATION_OPTION_ARGS})
    set (SANITIZATION_MULTIVAR_ARGS
         DEPENDS)

    cmake_parse_arguments (SANITIZATION
                           "${SANITIZATION_OPTION_ARGS}"
                           ""
                           "${SANITIZATION_MULTIVAR_ARGS}"
                           ${ARGN})

    cmake_forward_arguments (SANITIZATION SANITIZER_FORWARD_OPTIONS
                             OPTION_ARGS ${SANITIZATION_OPTION_ARGS}
                             MULTIVAR_ARGS ${SANITIZATION_MULTIVAR_ARGS})

    # Accelerate the sanitized target too
    psq_sanitizer_add_sanitization_to_target (${TARGET}
                                              ${SANITIZER_FORWARD_OPTIONS})
    cmake_forward_arguments (TARGET ACCELERATE_FWD_OPTS
                             OPTION_ARGS
                             ${PSQ_ALL_ACCELERATION_OPTION_ARGS}
                             MULTIVAR_ARGS
                             ${PSQ_ALL_ACCELERATION_MULTIVAR_ARGS})

    # Search for any targets ending in asan, msan, tsan and ubsan
    set (SANITIZERS_SUFFIXES asan msan tsan ubsan)

    foreach (SUFFIX ${SANITIZERS_SUFFIXES})

        if (TARGET ${TARGET}_${SUFFIX})

            psq_accelerate_target_compilation (${TARGET}_${SUFFIX}
                                               ${ACCELERATE_FWD_OPTS})

        endif ()

    endforeach ()

endfunction ()

function (_psq_add_target_internal TARGET)

    set (TARGET_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (TARGET_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (TARGET_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (TARGET
                           "${TARGET_OPTION_ARGS}"
                           "${TARGET_SINGLEVAR_ARGS}"
                           "${TARGET_MULTIVAR_ARGS}"
                           ${ARGN})

    get_property (PSQ_CFLAGS GLOBAL PROPERTY PSQ_CFLAGS)
    get_property (PSQ_CXXFLAGS GLOBAL PROPERTY PSQ_CXXFLAGS)
    get_property (PSQ_LDFLAGS GLOBAL PROPERTY PSQ_LDFLAGS)

    set_target_properties ("${TARGET}" PROPERTIES
                           COMPILE_FLAGS "${PSQ_CFLAGS} ${PSQ_CXXFLAGS}"
                           LINK_FLAGS "${PSQ_LDFLAGS}")

    if (TARGET_LIBRARIES)

        target_link_libraries (${TARGET}
                               ${TARGET_LIBRARIES})

    endif ()

    if (TARGET_DEPENDS)

        add_dependencies (${TARGET} ${TARGET_DEPENDS})

    endif ()

    if (TARGET_INTERNAL_INCLUDE_DIRS OR TARGET_EXTERNAL_INCLUDE_DIRS)

        # On older versions of CMake we need to use the directory-level
        # include_directories command
        if (CMAKE_VERSION VERSION_LESS 2.8.12)

            include_directories (SYSTEM ${TARGET_EXTERNAL_INCLUDE_DIRS})
            include_directories (${TARGET_INTERNAL_INCLUDE_DIRS})

        else ()

            if (TARGET_INTERNAL_INCLUDE_DIRS)

                set_property (TARGET ${TARGET}
                              APPEND PROPERTY INCLUDE_DIRECTORIES
                              ${TARGET_INTERNAL_INCLUDE_DIRS})

            endif ()

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

            endif ()

        endif ()

        # XCode won't mark system include dirs with -isystem, so append
        # -isystem ${EXTERNAL_INCLUDE_DIR} to the target's COMPILE_FLAGS for
        # now
        if (XCODE)

            foreach (EXTERNAL_INCLUDE_DIR ${TARGET_EXTERNAL_INCLUDE_DIRS})

                set_property (TARGET ${TARGET}
                              APPEND_STRING PROPERTY COMPILE_FLAGS
                              " -isystem ${EXTERNAL_INCLUDE_DIR}")

            endforeach ()

        endif ()

    endif ()

    foreach (DEFINE ${TARGET_DEFINES})

        add_definitions (-D${DEFINE})

    endforeach ()

    if (TARGET_EXPORT_HEADER_DIRECTORY)

        set_property (TARGET ${TARGET}
                      PROPERTY EXPORT_HEADER_DIRECTORY
                      "${TARGET_EXPORT_HEADER_DIRECTORY}")

    endif ()

    _psq_clear_variable_names_if_false (TARGET
                                        ${TARGET_OPTION_ARGS})

    cmake_forward_arguments (TARGET SANITIZATION_FORWARD_OPTIONS
                             OPTION_ARGS
                             ${PSQ_ALL_SANITIZATION_OPTION_ARGS}
                             MULTIVAR_ARGS
                             ${PSQ_ALL_SANITIZATION_MULTIVAR_ARGS})
    psq_add_sanitization_to_target (${TARGET}
                                    ${SANITIZATION_FORWARD_OPTIONS})

    cmake_forward_arguments (TARGET ACCELERATE_FORWARD_OPTIONS
                             OPTION_ARGS
                             ${PSQ_ALL_ACCELERATION_OPTION_ARGS}
                             MULTIVAR_ARGS
                             ${PSQ_ALL_ACCELERATION_MULTIVAR_ARGS})
    psq_accelerate_target_compilation (${TARGET}
                                       ${ACCELERATE_FORWARD_OPTIONS})

    # Make sure that we add checks to a target AFTER the target has been
    # accelerated. This enables us to add target_pch as a dependency
    # (which is necessary since the precompiled header file is not a
    #  source of the target and the rule will need to be run before
    #  any checks run)
    set (ADDITIONAL_CHECKS_DEPENDENCIES)
    if (TARGET ${TARGET}_pch)

        set (ADDITIONAL_CHECKS_DEPENDENCIES ${TARGET}_pch)

    endif ()

    cmake_forward_arguments (TARGET CHECKS_FORWARD_OPTIONS
                             OPTION_ARGS
                             ${PSQ_ALL_CHECKS_OPTION_ARGS}
                             SINGLEVAR_ARGS
                             ${PSQ_ALL_SOURCES_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS
                             ${PSQ_ALL_SOURCES_MULTIVAR_ARGS})
    psq_add_checks_to_target (${TARGET}
                              ${CHECKS_FORWARD_OPTIONS}
                              DEPENDS
                              ${ADDITIONAL_CHECKS_DEPENDENCIES}
                              ${CHECKS_DEPENDENCIES})

endfunction ()

function (psq_add_library LIBRARY_NAME LIBRARY_TYPE)

    set (LIBRARY_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (LIBRARY_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (LIBRARY_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (LIBRARY
                           "${LIBRARY_OPTION_ARGS}"
                           "${LIBRARY_SINGLEVAR_ARGS}"
                           "${LIBRARY_MULTIVAR_ARGS}"
                           ${ARGN})

    if (LIBRARY_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${LIBRARY_UNPARSED_ARGUMENTS} "
                 "given to psq_add_library")

    endif ()

    if (LIBRARY_LINK_DIRECTORIES)

        link_directories ("${LIBRARY_LINK_DIRECTORIES}")

    endif ()

    add_library (${LIBRARY_NAME}
                 ${LIBRARY_TYPE}
                 ${LIBRARY_SOURCES})
    generate_export_header ("${LIBRARY_NAME}")

    _psq_clear_variable_names_if_false (LIBRARY
                                        ${LIBRARY_OPTION_ARGS})

    cmake_forward_arguments (LIBRARY FORWARD_OPTIONS
                             OPTION_ARGS ${LIBRARY_OPTION_ARGS}
                             SINGLEVAR_ARGS ${LIBRARY_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${LIBRARY_MULTIVAR_ARGS})

    _psq_add_target_internal (${LIBRARY_NAME}
                              ${FORWARD_OPTIONS})

endfunction ()

function (psq_add_executable EXECUTABLE_NAME)

    set (EXECUTABLE_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (EXECUTABLE_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (EXECUTABLE_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (EXECUTABLE
                           "${EXECUTABLE_OPTION_ARGS}"
                           "${EXECUTABLE_SINGLEVAR_ARGS}"
                           "${EXECUTABLE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (EXECUTABLE_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${EXECUTABLE_UNPARSED_ARGUMENTS} "
                 "given to psq_add_executable")

    endif ()

    if (EXECUTABLE_LINK_DIRECTORIES)

        link_directories ("${EXECUTABLE_LINK_DIRECTORIES}")

    endif ()

    add_executable (${EXECUTABLE_NAME}
                    ${EXECUTABLE_SOURCES})

    _psq_clear_variable_names_if_false (EXECUTABLE
                                        ${EXECUTABLE_OPTION_ARGS})
    cmake_forward_arguments (EXECUTABLE FORWARD_OPTIONS
                             OPTION_ARGS ${EXECUTABLE_OPTION_ARGS}
                             SINGLEVAR_ARGS ${EXECUTABLE_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${EXECUTABLE_MULTIVAR_ARGS})

    _psq_add_target_internal (${EXECUTABLE_NAME}
                              ${FORWARD_OPTIONS})

endfunction ()

macro (_psq_add_gtest_includes_and_libraries EXTERNAL_INCLUDE_DIRS_VAR
                                             LIBRARIES_VAR
                                             LINK_DIRECTORIES_VAR)

    list (APPEND ${EXTERNAL_INCLUDE_DIRS_VAR}
          "${GTEST_INCLUDE_DIR}"
          "${GMOCK_INCLUDE_DIR}")

    list (APPEND ${LIBRARIES_VAR}
          ${GTEST_LIBRARY}
          ${GMOCK_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT})

    list (APPEND ${LINK_DIRECTORIES_VAR}
          ${GTEST_LIBRARY_DIRS})

endmacro ()

macro (_psq_add_library_export_headers LIBRARY
                                       INCLUDE_DIRS_VAR
                                       LIBRARIES_VAR)

    list (APPEND ${LIBRARIES_VAR}
          ${LIBRARY})

    get_property (EXPORT_HEADER_DIRECTORY
                  TARGET ${LIBRARY}
                  PROPERTY EXPORT_HEADER_DIRECTORY)

    list (APPEND ${INCLUDE_DIRS_VAR}
          "${EXPORT_HEADER_DIRECTORY}")

endmacro ()

function (psq_add_test TEST_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif ()

    set (TEST_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (TEST_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS}
         MAIN_LIBRARY)
    set (TEST_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS}
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
                 "psq_add_test")

    endif ()

    _psq_add_gtest_includes_and_libraries (TEST_EXTERNAL_INCLUDE_DIRS
                                           TEST_LIBRARIES
                                           TEST_LINK_DIRECTORIES)

    if (TEST_MAIN_LIBRARY)

        list (APPEND TEST_LIBRARIES ${TEST_MAIN_LIBRARY})

    else ()

        list (APPEND TEST_LIBRARIES ${GMOCK_MAIN_LIBRARY})

    endif ()

    foreach (MATCHER ${TEST_MATCHERS})

        _psq_add_library_export_headers (${MATCHER}
                                         TEST_INTERNAL_INCLUDE_DIRS
                                         TEST_LIBRARIES)

    endforeach ()

    foreach (MOCK ${TEST_MOCKS})

        _psq_add_library_export_headers (${MOCK}
                                         TEST_INTERNAL_INCLUDE_DIRS
                                         TEST_LIBRARIES)

    endforeach ()

    _psq_clear_variable_names_if_false (TEST
                                        ${TEST_OPTION_ARGS})
    cmake_forward_arguments (TEST FORWARD_OPTIONS
                             OPTION_ARGS
                             ${PSQ_ALL_BINARY_OPTION_ARGS}
                             SINGLEVAR_ARGS
                             ${PSQ_ALL_BINARY_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS
                             ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    psq_add_executable (${TEST_NAME}
                        ${FORWARD_OPTIONS})

endfunction ()

function (psq_add_test_main MAIN_LIBRARY_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif ()

    set (MAIN_LIBRARY_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (MAIN_LIBRARY_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (MAIN_LIBRARY_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (MAIN_LIBRARY
                           "${MAIN_LIBRARY_OPTION_ARGS}"
                           "${MAIN_LIBRARY_SINGLEVAR_ARGS}"
                           "${MAIN_LIBRARY_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MAIN_LIBRARY_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MAIN_LIBRARY_UNPARSED_ARUGMENTS}"
                 " given to psq_add_main_library")

    endif ()

    set (MAIN_LIB_EXT_INC_DIRS ${MAIN_LIBRARY_EXTERNAL_INCLUDE_DIRS})

    _psq_add_gtest_includes_and_libraries (MAIN_LIB_EXT_INC_DIRS
                                           MAIN_LIBRARY_LIBRARIES
                                           MAIN_LIBRARY_LINK_DIRECTORIES)

    # Make sure to expand MAIN_LIB_EXT_INC_DIRS for cmake_forward_arguments
    set (MAIN_LIBRARY_EXTERNAL_INCLUDE_DIRS ${MAIN_LIB_EXT_INC_DIRS})

    _psq_clear_variable_names_if_false (MAIN_LIBRARY
                                        ${MAIN_LIBRARY_OPTION_ARGS})

    cmake_forward_arguments (MAIN_LIBRARY FORWARD_OPTIONS
                             OPTION_ARGS ${MAIN_LIBRARY_OPTION_ARGS}
                             SINGLEVAR_ARGS ${MAIN_LIBRARY_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${MAIN_LIBRARY_MULTIVAR_ARGS})

    psq_add_library (${MAIN_LIBRARY_NAME} STATIC
                     ${FORWARD_OPTIONS})

endfunction ()

function (psq_add_matcher MATCHER_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif ()

    set (MATCHER_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (MATCHER_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (MATCHER_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (MATCHER
                           "${MATCHER_OPTION_ARGS}"
                           "${MATCHER_SINGLEVAR_ARGS}"
                           "${MATCHER_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MATCHER_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MATCHER_UNPARSED_ARUGMENTS} given to"
                 " psq_add_matcher")

    endif ()

    _psq_add_gtest_includes_and_libraries (MATCHER_EXTERNAL_INCLUDE_DIRS
                                           MATCHER_LIBRARIES
                                           MATCHER_LINK_DIRECTORIES)

    _psq_clear_variable_names_if_false (MATCHER
                                        ${MATCHER_OPTION_ARGS})

    cmake_forward_arguments (MATCHER FORWARD_OPTIONS
                             OPTION_ARGS ${MATCHER_OPTION_ARGS}
                             SINGLEVAR_ARGS ${MATCHER_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${MATCHER_MULTIVAR_ARGS})

    psq_add_library (${MATCHER_NAME} STATIC
                     ${FORWARD_OPTIONS})

endfunction ()

function (psq_add_mock MOCK_NAME)

    if (NOT POLYSQUARE_BUILD_TESTS)

        return ()

    endif ()

    set (MOCK_OPTION_ARGS
         ${PSQ_ALL_BINARY_OPTION_ARGS})
    set (MOCK_SINGLEVAR_ARGS
         ${PSQ_ALL_BINARY_SINGLEVAR_ARGS})
    set (MOCK_MULTIVAR_ARGS
         ${PSQ_ALL_BINARY_MULTIVAR_ARGS})

    cmake_parse_arguments (MOCK
                           "${MOCK_OPTION_ARGS}"
                           "${MOCK_SINGLEVAR_ARGS}"
                           "${MOCK_MULTIVAR_ARGS}"
                           ${ARGN})

    if (MOCK_UNPARSED_ARGUMENTS)

        message (FATAL_ERROR
                 "Unrecognized arguments ${MOCK_UNPARSED_ARUGMENTS} given to "
                 "psq_add_mock")

    endif ()

    _psq_add_gtest_includes_and_libraries (MOCK_EXTERNAL_INCLUDE_DIRS
                                           MOCK_LIBRARIES
                                           MOCK_LINK_DIRECTORIES)

    _psq_clear_variable_names_if_false (MOCK
                                        ${MOCK_OPTION_ARGS})

    cmake_forward_arguments (MOCK FORWARD_OPTIONS
                             OPTION_ARGS ${MOCK_OPTION_ARGS}
                             SINGLEVAR_ARGS ${MOCK_SINGLEVAR_ARGS}
                             MULTIVAR_ARGS ${MOCK_MULTIVAR_ARGS})

    psq_add_library (${MOCK_NAME} STATIC
                     ${FORWARD_OPTIONS})

endfunction ()
