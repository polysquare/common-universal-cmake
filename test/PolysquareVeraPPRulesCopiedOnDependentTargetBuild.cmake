# /tests/PolysquareVeraPPRulesCopiedOnDependentTargetBuild.cmake
# Bootstraps polysquare's Vera++ rules and profiles and then adds
# a target dependent on the import rule so that they will be
# copied at build time
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/scripts)

add_custom_target (force_import_rules ALL
                   DEPENDS
                   polysquare_verapp_copy_rules
                   polysquare_verapp_copy_profiles
                   polysquare_verapp_import_rules)
