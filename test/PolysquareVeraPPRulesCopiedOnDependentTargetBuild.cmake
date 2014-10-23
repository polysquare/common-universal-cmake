# /tests/PolysquareVeraPPRulesCopiedOnDependentTargetBuild.cmake
# Bootstraps polysquare's Vera++ rules and profiles and then adds
# a target dependent on the import rule so that they will be
# copied at build time
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap ()

add_custom_target (force_import_rules ALL
                   DEPENDS
                   polysquare_verapp_copy_rules
                   polysquare_verapp_copy_profiles
                   polysquare_verapp_import_rules)
