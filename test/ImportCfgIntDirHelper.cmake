# /tests/ImportCfgIntDirHelper.cmake
#
# Imports the written out CFG_INTDIR and stores it in CMAKE_CFG_INTDIR
#
# See LICENCE.md for Copyright information

file (READ ${CMAKE_CURRENT_BINARY_DIR}/CfgIntDirValue.txt CMAKE_CFG_INTDIR)