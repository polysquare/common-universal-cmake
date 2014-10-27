# /tests/ExportCfgIntDirHelper.cmake
#
# Writes out CMAKE_CFG_INTDIR to ${CMAKE_CURRENT_BINARY_DIR}/CfgIntDirValue.txt
# at build time
#
# See LICENCE.md for Copyright information

set (OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/CfgIntDirValue.txt)
set (WRITE_TO_OUTPUT_FILE_SCRIPT
     ${CMAKE_CURRENT_BINARY_DIR}/WriteCfgIntDir.cmake)
set (WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS
     "file (WRITE ${OUTPUT_FILE} \"\${INTDIR}\")\n")
file (WRITE ${WRITE_TO_OUTPUT_FILE_SCRIPT}
      "${WRITE_TO_OUTPUT_FILE_SCRIPT_CONTENTS}")
add_custom_command (OUTPUT ${OUTPUT_FILE}
                    COMMAND ${CMAKE_COMMAND}
                    -DINTDIR=${CMAKE_CFG_INTDIR}
                    -P ${WRITE_TO_OUTPUT_FILE_SCRIPT})
add_custom_target (write_cfg_int_dir ALL
                   SOURCES ${OUTPUT_FILE})