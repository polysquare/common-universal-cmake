# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

cmake_minimum_required (VERSION 2.8)

function (_get_real_library_path LIBRARY RESULT)

    if (DEFINED LIBRARY)

        set (location_)
        if (TARGET ${LIBRARY})
            get_property (_location TARGET ${LIBRARY} PROPERTY LOCATION)
        endif (TARGET ${LIBRARY})

        # If a location is set, we should use that one, otherwise
        # just pass the linker line of the library.
        if (_location)
            set (${RESULT} ${_location} PARENT_SCOPE)
        else (_location)
            set (${RESULT} ${LIBRARY} PARENT_SCOPE)
        endif (_location)

    endif (DEFINED LIBRARY)

endfunction (_get_real_library_path)

# We assume that it is one-above us
set (POLYSQUARE_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                        ${POLYSQUARE_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)

# We build a copy of Google Test locally and then specify its location in
# the cache. This allows the tests to immediately use that copy as opposed
# to having to download it all the time.
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cmake-unit)

_get_real_library_path (${GTEST_LIBRARY} REAL_GTEST_LIBRARY)
_get_real_library_path (${GMOCK_LIBRARY} REAL_GMOCK_LIBRARY)
_get_real_library_path (${GTEST_MAIN_LIBRARY} REAL_GTEST_MAIN_LIBRARY)
_get_real_library_path (${GMOCK_MAIN_LIBRARY} REAL_GMOCK_MAIN_LIBRARY)

# Put our directories into the cache as well as the parameters for the
# Google Test distribution.
set (POLYSQUARE_INITIAL_CACHE_CONTENTS
     "set (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY\n"
     "     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GTEST_EXTERNAL_SET_INCLUDE_DIR\n"
     "     ${GTEST_INCLUDE_DIR}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GMOCK_EXTERNAL_SET_INCLUDE_DIR\n"
     "     ${GMOCK_INCLUDE_DIR}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GTEST_EXTERNAL_SET_LIBRARY\n"
     "     ${REAL_GTEST_LIBRARY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GMOCK_EXTERNAL_SET_LIBRARY\n"
     "     ${REAL_GMOCK_LIBRARY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GTEST_EXTERNAL_SET_MAIN_LIBRARY\n"
     "     ${REAL_GTEST_MAIN_LIBRARY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GMOCK_EXTERNAL_SET_MAIN_LIBRARY\n"
     "     ${REAL_GMOCK_MAIN_LIBRARY}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      POLYSQUARE_INITIAL_CACHE_CONTENTS)

add_cmake_test (AddPolysquareCommonAsSubdirectory)
add_cmake_test (AddSourcesScanTargetLanguageSet)
add_cmake_test (CompilerFlagsSetAfterCompilerBootstrap)
add_cmake_test (CoverageFlagsSetForGCCAfterCoverageBootstrap)
add_cmake_test (CoverageFlagsNotSetForClangAfterCoverageBootstrap)
add_cmake_test (NoBuildTestsOption)
add_cmake_test (NoWErrorOption)
add_cmake_test (VeraPPRulesSetAfterRulesBootstrap)
add_cmake_test (TestLibrariesAvailableAfterGoogleTestBootstrap)
add_cmake_build_test (AddSourcesScanTarget
                      AddSourcesScanTargetVerify)
add_cmake_build_test (AddTestTargetLinkedToLibraries VerifyGTest)
add_cmake_build_test (AddTestLinkedToMatcher VerifyGTest)
add_cmake_build_test (AddTestLinkedToMock VerifyGTest)
add_cmake_build_test (AddTestLinkedToMainLibrary VerifyGTest)
add_cmake_build_test (ExternalHeadersAreSystemHeaders
                      ExternalHeadersAreSystemHeadersVerify)
add_cmake_build_test (PolysquareVeraPPRulesCopiedOnDependentTargetBuild
                      PolysquareVeraPPRulesCopiedOnDependentTargetBuildVerify)
add_cmake_build_test (NoCPPCheckOption
                      NoCPPCheckOptionVerify)
add_cmake_build_test (NoVeraPPOption
                      NoVeraPPOptionVerify)
add_cmake_build_test (VeraPPWithPolysquareProfileRunOnTargetWithRules
                      VeraPPWithPolysquareProfileRunOnTargetWithRulesVerify)
add_cmake_build_test (CPPCheckRunWithCorrectIncludeDirs
                      CPPCheckRunWithCorrectIncludeDirsVerify)
add_cmake_build_test (CPPChecksAllInternalHeadersOnGlobalUnusedCheck
                      CPPChecksAllInternalHeadersOnGlobalUnusedCheckVerify)
add_cmake_test (AddMatcherTarget)
add_cmake_test (MatcherTargetHasExportedDetails)
add_cmake_test (AddMockTarget)
add_cmake_test (MockTargetHasExportedDetails)
