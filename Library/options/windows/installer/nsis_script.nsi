Icon "${ICON_FILE}"
RequestExecutionLevel user
OutFile "${INSTALLER_FILENAME}"
SilentInstall silent
Section "${PRODUCT_NAME}"
    SetOutPath `$TEMP\${PRODUCT_NAME}`
    File /r "${SOURCE_DIR}\*.*"
    ExecWait `$TEMP\${PRODUCT_NAME}\${EXE_NAME}.exe -install "${INSTDIR}"`
    RMDir /r `$TEMP\${PRODUCT_NAME}`
SectionEnd