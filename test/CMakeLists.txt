# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (PolysquareCommonUniversalCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (POLYSQUARE_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                        ${POLYSQUARE_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cmake-unit)

set (CMAKE_MODULE_PATH
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_CURRENT_SOURCE_DIR}
     ${CMAKE_MODULE_PATH})

# We build a copy of Google Test locally and then specify its location in
# the cache. This allows the tests to immediately use that copy as opposed
# to having to download it all the time.
include (PolysquareCommon)

polysquare_gmock_bootstrap ()

# Check for the presence of Vera++, CPPCheck, include-what-you-use
# and clang-tidy
polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR})

# Check for the presence of AddressSanitizer, MemorySanitizer, ThreadSanitizer,
# UndefinedBehaviourSanitizer. If any of these get set to OFF, the sanitizer
# is not available.
set (SANITIZERS_USE_ASAN ON CACHE FORCE "")
set (SANITIZERS_USE_MSAN ON CACHE FORCE "")
set (SANITIZERS_USE_TSAN ON CACHE FORCE "")
set (SANITIZERS_USE_UBSAN ON CACHE FORCE "")

polysquare_sanitizers_bootstrap ()

include (CMakeUnitRunner)

bootstrap_cmake_unit (VARIABLES CMAKE_MODULE_PATH
                                POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                                GTEST_INCLUDE_DIR
                                GMOCK_INCLUDE_DIR
                                GTEST_LIBRARY_LOCATION
                                GMOCK_LIBRARY_LOCATION
                                GTEST_MAIN_LIBRARY_LOCATION
                                GMOCK_MAIN_LIBRARY_LOCATION
                                CMAKE_CXX_COMPILER
                                CMAKE_C_COMPILER
                                CMAKE_CXX_FLAGS
                                CMAKE_C_FLAGS
                                CMAKE_CFG_INTDIR
                                CPPCHECK_VERSION
                                CMAKE_GENERATOR)

add_cmake_test (AddPolysquareCommonAsSubdirectory)
add_cmake_test (CompilerFlagsSetAfterCompilerBootstrap)
add_cmake_test (CoverageFlagsSetForGCCAfterCoverageBootstrap)
add_cmake_test (CoverageFlagsNotSetForClangAfterCoverageBootstrap)
add_cmake_test (NoBuildTestsOption)
add_cmake_test (NoWErrorOption)
add_cmake_test (PrefixHeaderClearedOnTarget)
add_cmake_test (VeraPPRulesSetAfterRulesBootstrap)
add_cmake_test (TestLibrariesAvailableAfterGoogleTestBootstrap)
add_cmake_test (CheckSourcesTargetCreated)
add_cmake_test (PCHTargetsGeneratedAfterCotireBootstrap)
add_cmake_test (UnityBuildTargetsGeneratedAfterCotireBootstrap)
add_cmake_test (NoUnityBuildOption)
add_cmake_test (NoUnityBuildGlobalOption)
add_cmake_test (NoPCHOption)
add_cmake_test (NoPCHGlobalOption)
add_cmake_build_test (UnityBuildTargetsInheritTargetLinkLibraries
                      UnityBuildTargetsInheritTargetLinkLibrariesVerify
                      TARGET all_unity)
add_cmake_build_test (UnityBuildTargetsDependOnUnityDependencies
                      UnityBuildTargetsDependOnUnityDependenciesVerify
                      TARGET all_unity)
add_cmake_build_test (UnityBuildTargetsInheritDependencies
                      UnityBuildTargetsInheritDependenciesVerify
                      TARGET all_unity)
add_cmake_build_test (UseFilesInBuildDirectoryInPCHFile
                      UseFilesInBuildDirectoryInPCHFileVerify)
add_cmake_build_test (SkipGeneratedFilesInPCHFile
                      SkipGeneratedFilesInPCHFileVerify)
add_cmake_build_test (DependenciesLinkedToTarget
                      DependenciesLinkedToTargetVerify)
add_cmake_build_test (AddSourcesScanTarget
                      AddSourcesScanTargetVerify)
add_cmake_build_test (AddTestTargetLinkedToLibraries VerifyGTest)
add_cmake_build_test (AddTestLinkedToMatcher VerifyGTest)
add_cmake_build_test (AddTestLinkedToMock VerifyGTest)
add_cmake_build_test (AddTestLinkedToMainLibrary VerifyGTest)
add_cmake_build_test (CheckSourcesRunWithCorrectIncludeDirs
                      CheckSourcesRunWithCorrectIncludeDirsVerify)
add_cmake_build_test (CheckSourcesRunWithCorrectDefines
                      CheckSourcesRunWithCorrectDefinesVerify)
add_cmake_build_test (CheckSourcesRunWithCPPIdentifiers
                      CheckSourcesRunWithCPPIdentifiersVerify)
add_cmake_build_test (CheckSourcesRunWithForcedLanguage
                      CheckSourcesRunWithForcedLanguageVerify)
add_cmake_build_test (ExternalHeadersAreSystemHeaders
                      ExternalHeadersAreSystemHeadersVerify)
add_cmake_build_test (PolysquareVeraPPRulesCopiedOnDependentTargetBuild
                      PolysquareVeraPPRulesCopiedOnDependentTargetBuildVerify)
add_cmake_build_test (NoCPPCheckOption
                      NoCPPCheckOptionVerify)
add_cmake_build_test (NoClangTidyOption
                      NoClangTidyOptionVerify)
add_cmake_build_test (NoCPPCheckUnusedOption
                      NoCPPCheckUnusedOptionVerify)
add_cmake_build_test (NoIncludeWhatYouUseOption
                      NoIncludeWhatYouUseOptionVerify)
add_cmake_build_test (NoCPPCheckUnusedGeneratedOption
                      NoCPPCheckUnusedGeneratedOptionVerify)
add_cmake_build_test (NoVeraPPOption
                      NoVeraPPOptionVerify)
add_cmake_build_test (VeraPPWithPolysquareProfileRunOnTargetWithRules
                      VeraPPWithPolysquareProfileRunOnTargetWithRulesVerify)
add_cmake_build_test (CPPCheckRunWithCorrectIncludeDirs
                      CPPCheckRunWithCorrectIncludeDirsVerify)
add_cmake_build_test (CPPChecksAllInternalHeadersOnGlobalUnusedCheck
                      CPPChecksAllInternalHeadersOnGlobalUnusedCheckVerify)
add_cmake_build_test (ClangTidyEnableChecksPassed
                      ClangTidyEnableChecksPassedVerify)
add_cmake_build_test (ClangTidyDisableChecksPassed
                      ClangTidyDisableChecksPassedVerify)
add_cmake_build_test (OverrideUnusedCheckWithGroupProperty
                      OverrideUnusedCheckWithGroupPropertyVerify)
add_cmake_build_test (ChecksCanBeRunOnGeneratedFiles
                      ChecksCanBeRunOnGeneratedFilesVerify)
add_cmake_build_test (CheckSourcesStampfileGenerated
                      CheckSourcesStampfileGeneratedVerify)
add_cmake_build_test (CheckSourcesReRunIfSourcesUpdated
                      CheckSourcesReRunIfSourcesUpdatedVerify)
add_cmake_test (AddMatcherTarget)
add_cmake_test (MatcherTargetHasExportedDetails)
add_cmake_test (AddMockTarget)
add_cmake_test (MockTargetHasExportedDetails)
add_cmake_test (GlobalUnusedFunctionCheckByDefault)

# Only add these tests if we have AddressSanitizer support
if (SANITIZERS_USE_ASAN)

    # Many of these tests are applicable to ThreadSanitizer, MemorySanitizer
    # and UndefinedBehaviourSanitizer. Since AddressSanitizer is the most
    # widely available sanitizer, we'll add these tests on AddressSanitizer
    # only to prevent duplication
    add_cmake_test (NoASanFlagDisablesCreationOfInstrumentedBinary)
    add_cmake_test (NoCreateASanInstrumentedBinaryOnUserDisable)
    add_cmake_test (CreateUnityASanInstrumentedBinary)
    add_cmake_test (CreateASanInstrumentedBinaryWithPCH)
    add_cmake_build_test (CreateASanInstrumentedBinary
                          CreateASanInstrumentedBinaryVerify)
    add_cmake_build_test (CreateASanInstrumentedLibrary
                          CreateASanInstrumentedLibraryVerify)
    add_cmake_build_test (ASanInstrumentedBinaryLinksToInstrumentedLibrary
                          ASanInstrumentedBinaryLinksToInstrumentedLibraryVerify)

endif (SANITIZERS_USE_ASAN)

if (SANITIZERS_USE_MSAN)

    add_cmake_build_test (CreateMSanInstrumentedBinary
                          CreateMSanInstrumentedBinaryVerify)

    if (SANITIZERS_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS)

        add_cmake_build_test (MSanInstrumentedBinaryTracksOrigins
                              MSanInstrumentedBinaryTracksOriginsVerify)

    endif (SANITIZERS_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS)

endif (SANITIZERS_USE_MSAN)

if (SANITIZERS_USE_UBSAN)

    add_cmake_build_test (CreateUBSanInstrumentedBinary
                          CreateUBSanInstrumentedBinaryVerify)

    if (SANITIZERS_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW)

        add_cmake_build_test (UBSanInstrumentedBinaryUnsignedIntOverflow
                              UBSanInstrumentedBinaryUnsignedIntOverflowVerify)

    endif (SANITIZERS_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW)

    if (SANITIZERS_HAVE_UBSAN_NO_SANITIZE_RECOVER)

        add_cmake_build_test (UBSanInstrumentedBinaryNoRecover
                              UBSanInstrumentedBinaryNoRecoverVerify)

    endif (SANITIZERS_HAVE_UBSAN_NO_SANITIZE_RECOVER)


endif (SANITIZERS_USE_UBSAN)

if (SANITIZERS_USE_TSAN)

    add_cmake_build_test (CreateTSanInstrumentedBinary
                          CreateTSanInstrumentedBinaryVerify)

endif (SANITIZERS_USE_TSAN)

# Support for CMAKE_EXPORT_COMPILE_COMMANDS is being enabled on a per-generator
# basis at this point
if (CMAKE_GENERATOR STREQUAL "Ninja" OR
    CMAKE_GENERATOR STREQUAL "Unix Makefiles")

  add_cmake_build_test (GenerateCompilationCommandsDatabaseAfterBootstrap
                        GenerateCompilationCommandsDatabaseAfterBootstrapVerify)

endif (CMAKE_GENERATOR STREQUAL "Ninja" OR
       CMAKE_GENERATOR STREQUAL "Unix Makefiles")