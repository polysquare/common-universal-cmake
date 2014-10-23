# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (PolysquareCommonUniversalCMakeTests)
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

set (CMAKE_MODULE_PATH
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
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

set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cmake-unit)

_get_real_library_path (${GTEST_LIBRARY} REAL_GTEST_LIBRARY)
_get_real_library_path (${GMOCK_LIBRARY} REAL_GMOCK_LIBRARY)
_get_real_library_path (${GTEST_MAIN_LIBRARY} REAL_GTEST_MAIN_LIBRARY)
_get_real_library_path (${GMOCK_MAIN_LIBRARY} REAL_GMOCK_MAIN_LIBRARY)

# Put our directories into the cache as well as the parameters for the
# Google Test distribution.
set (GTEST_EXTERNAL_SET_INCLUDE_DIR ${GTEST_INCLUDE_DIR})
set (GMOCK_EXTERNAL_SET_INCLUDE_DIR ${GMOCK_INCLUDE_DIR})
set (GTEST_EXTERNAL_SET_LIBRARY ${REAL_GTEST_LIBRARY})
set (GMOCK_EXTERNAL_SET_LIBRARY ${REAL_GMOCK_LIBRARY})
set (GTEST_EXTERNAL_SET_MAIN_LIBRARY ${REAL_GTEST_MAIN_LIBRARY})
set (GMOCK_EXTERNAL_SET_MAIN_LIBRARY ${REAL_GMOCK_MAIN_LIBRARY})

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (VARIABLES CMAKE_MODULE_PATH
                                POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                                GTEST_EXTERNAL_SET_INCLUDE_DIR
                                GMOCK_EXTERNAL_SET_INCLUDE_DIR
                                GTEST_EXTERNAL_SET_LIBRARY
                                GMOCK_EXTERNAL_SET_LIBRARY
                                GTEST_EXTERNAL_SET_MAIN_LIBRARY
                                GMOCK_EXTERNAL_SET_MAIN_LIBRARY
                                CMAKE_CXX_COMPILER
                                CMAKE_C_COMPILER
                                CMAKE_CXX_FLAGS
                                CMAKE_C_FLAGS
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
add_cmake_build_test (GenerateCompilationCommandsDatabaseAfterBootstrap
                      GenerateCompilationCommandsDatabaseAfterBootstrapVerify)
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
