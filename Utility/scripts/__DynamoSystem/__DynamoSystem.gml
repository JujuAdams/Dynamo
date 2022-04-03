#macro __DYNAMO_VERSION    "0.0.1"
#macro __DYNAMO_DATE       "2022-04-02"
#macro __DYNAMO_TEST_MODE  true

global.__dynamoRunningFromIDE = __DynamoRunningFromIDE();

global.__dynamoManifestLoaded     = false;
global.__dynamoManifestDictionary = {};

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

global.__dynamoDictionary = {};

function __DynamoTrace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Dynamo: " + _string);
}

function __DynamoLoud()
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

function __DynamoQuestion()
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

function __DynamoError()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_error("Dynamo:\n\n" + _string + "\n ", true);
}

function __DynamoBufferSave(_buffer, _filename, _tell = buffer_get_size(_buffer))
{
    if (DYNAMO_COMPRESS)
    {
        var _compressedBuffer = buffer_compress(_buffer, 0, _tell);
        buffer_save(_compressedBuffer, _filename);
        buffer_delete(_compressedBuffer);
    }
    else
    {
        buffer_save(_buffer, _filename);
    }
}

function __DynamoNameHash(_name)
{
    return md5_string_utf8(_name);
}

function __DynamoEnsureManifestLoaded()
{
    if (global.__dynamoManifestLoaded) return;
    
    var _buffer = buffer_load("dynamo_manifest");
    buffer_delete(_buffer);
}
