# /tests/CompilerFlagsSetAfterCompilerBootstrap.cmake
# Tests that we can add common-universal-cmake as a
# a subdirectory.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap ()

assert_target_exists (polysquare_verapp_copy_rules)
assert_target_exists (polysquare_verapp_copy_profiles)
assert_target_exists (polysquare_verapp_import_rules)

assert_variable_is (_POLYSQUARE_VERAPP_PROFILE STRING EQUAL "polysquare")
assert_variable_is (_POLYSQUARE_VERAPP_IMPORT_RULES
                    STRING
                    EQUAL
                    "polysquare_verapp_import_rules")
