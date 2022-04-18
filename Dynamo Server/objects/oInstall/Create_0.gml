/*
Icon "${ICON_FILE}"
RequestExecutionLevel user
OutFile "${INSTALLER_FILENAME}"
SilentInstall silent
Section "${PRODUCT_NAME}"
    SetOutPath `$TEMP\${PRODUCT_NAME}`
    File /r "${SOURCE_DIR}\*.*"
    ExecWait `$TEMP\${PRODUCT_NAME}\${EXE_NAME}.exe "$CMDLINE"`
    RMDir /r `$TEMP\${PRODUCT_NAME}`
SectionEnd
*/

__showMessage = function()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Dynamo: " + _string);
    show_message(_string);
}

__showQuestion = function()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return show_question(_string);
}

alarm[0] = 1;