# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

# We assume that it is one-above us
set (POLYSQUARE_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                        ${POLYSQUARE_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cmake-unit)

set (POLYSQUARE_INITIAL_CACHE_CONTENTS
     "set (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY\n"
     "     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      POLYSQUARE_INITIAL_CACHE_CONTENTS)

add_cmake_test (AddPolysquareCommonAsSubdirectory)
add_cmake_test (CompilerFlagsSetAfterCompilerBootstrap)
add_cmake_test (CoverageFlagsSetForGCCAfterCoverageBootstrap)
add_cmake_test (CoverageFlagsNotSetForClangAfterCoverageBootstrap)
add_cmake_test (NoBuildTestsOption)
add_cmake_test (VeraPPRulesSetAfterRulesBootstrap)
add_cmake_test (TestLibrariesAvailableAfterGoogleTestBootstrap)
add_cmake_build_test (AddSourcesScanTarget
                      AddSourcesScanTargetVerify)
add_cmake_build_test (AddTestTargetLinkedToLibraries VerifyGTest)
add_cmake_build_test (AddTestLinkedToMatcher VerifyGTest)
add_cmake_build_test (AddTestLinkedToMock VerifyGTest)
add_cmake_build_test (PolysquareVeraPPRulesCopiedOnDependentTargetBuild
                      PolysquareVeraPPRulesCopiedOnDependentTargetBuildVerify)
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
add_cmake_test (GeneratedSourcesNotAddedToSources)
