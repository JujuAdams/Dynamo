//Not exposed yet but will be eventually
#macro DYNAMO_COMPRESS  false

#macro __DYNAMO_VERSION    "0.0.1"
#macro __DYNAMO_DATE       "2022-04-02"
#macro __DYNAMO_DEV_MODE   (DYNAMO_DEV_MODE && global.__dynamoRunningFromIDE)

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);



global.__dynamoInFocus = true;

global.__dynamoNoteDictionaryBuilt = false;
global.__dynamoNoteDictionary = {};



global.__dynamoRunningFromIDE = false;

if (code_is_compiled() && (parameter_count() == 1))
{
    var _path = filename_dir(parameter_string(0));
    
    var _last_folder = _path;
    do
    {
        var _pos = string_pos("\\", _last_folder);
        if (_pos > 0) _last_folder = string_delete(_last_folder, 1, _pos);
    }
    until (_pos <= 0);
    
    var _last_four = string_copy(_last_folder, string_length(_last_folder) - 3, 4);
    var _filename = filename_change_ext(filename_name(parameter_string(0)), "");
    
    if ((_last_four == "_YYC")
    &&  (string_length(_last_folder) - string_length(_filename) == 13))
    {
        global.__dynamoRunningFromIDE = true;
    }
}
else
{
    if ((parameter_count() == 3)
    &&  (filename_name(parameter_string(0)) == "Runner.exe")
    &&  (parameter_string(1) == "-game")
    &&  (filename_ext(parameter_string(2)) == ".win"))
    {
        global.__dynamoRunningFromIDE = true;
    }
}



global.__dynamoProjectDirectory = undefined;
if (DYNAMO_LOAD_MANIFEST_ON_BOOT) __DynamoEnsureManifest();



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

function __DynamoEnsureManifest()
{
    if (global.__dynamoNoteDictionaryBuilt) return;
    global.__dynamoNoteDictionaryBuilt = true;
    
    if (__DYNAMO_DEV_MODE)
    {
        if (!file_exists("projectDirectory.dynamo"))
        {
            __DynamoError("Could not find project directory link file\nPlease ensure Dynamo has been set up by running dynamo.exe in the project's root directory");
            return;
        }
        else
        {
            try
            {
                var _buffer = buffer_load("projectDirectory.dynamo");
            }
            catch(_error)
            {
                __DynamoError("Caught an exception whilst loading project directory link file");
            }
                
            if (_buffer < 0)
            {
                __DynamoError("Failed to load project directory link file");
            }
            
            global.__dynamoProjectDirectory = buffer_read(_buffer, buffer_text);
            buffer_delete(_buffer);
            
            //Trim off any invalid characters at the end of the project directory string
            var _i = string_length(global.__dynamoProjectDirectory);
            repeat(_i)
            {
                if (ord(string_char_at(global.__dynamoProjectDirectory, _i)) >= 32) break;
                --_i;
            }
            
            global.__dynamoProjectDirectory = string_copy(global.__dynamoProjectDirectory, 1, _i);
        }
        
        var _json = __DynamoParseMainProjectJSON(global.__dynamoProjectDirectory);
        var _noteArray = __DynamoMainProjectNotesArray(_json, global.__dynamoProjectDirectory);
    }
    else
    {
        var _noteArray = __DynamoManifestNotesArray("manifest.dynamo");
    }
    
    //And initialize hashes for each asset
    var _i = 0;
    repeat(array_length(_noteArray))
    {
        _noteArray[_i].__HashInitialize();
        ++_i;
    }
}

function __DynamoParseMainProjectJSON(_directory)
{
    //Try to find a project file in this directory
    var _count = 0;
    var _file = file_find_first(_directory + "*.yyp", 0);
    var _projectPath = _directory + _file;
    
    while(_file != "")
    {
        ++_count;
        _file = file_find_next();
    }
    
    file_find_close();
    
    //Report errors if we cannot find 
    if (_count <= 0)
    {
        __DynamoError("No main project file (.yyp) found in \"", _directory, "\"\nPlease check that \"Disable file system sandbox\" is enabled in Game Options");
        return;
    }
    else if (_count > 1)
    {
        __DynamoError("More than .yyp file found in \"", _directory, "\"");
        return;
    }
    
    try
    {
        var _projectBuffer = buffer_load(_projectPath);
        var _string = buffer_read(_projectBuffer, buffer_text);
        buffer_delete(_projectBuffer);
    }
    catch(_error)
    {
        __DynamoError("Failed to load main project file \"", _projectPath, "\"");
        return;
    }
    
    __DynamoTrace("Loaded \"", _projectPath, "\"");
    
    try
    {
        var _json = json_parse(_string);
    }
    catch(_error)
    {
        __DynamoError("Failed to parse JSON in main project file \"", _projectPath, "\"");
        return;
    }
    
    __DynamoTrace("Parsed main project file");
    
    var _resourceType = _json[$ "resourceType"];
    if (_resourceType != "GMProject")
    {
        __DynamoError(".yyp file \"", _projectPath, "\" not recognised as a main project JSON\nResource type was \"", _resourceType, "\"");
        return;
    }
    
    return _json;
}

function __DynamoMainProjectNotesArray(_projectJSON, _directory)
{
    __DynamoTrace("Searching for notes in main project JSON");
    
    global.__dynamoNoteDictionary = {};
    var _array = [];
    
    var _resourcesArray = _projectJSON[$ "resources"];
    if (_resourcesArray != undefined)
    {
        var _i = 0;
        repeat(array_length(_resourcesArray))
        {
            var _resourceStruct = _resourcesArray[_i].id;
            var _path = _resourceStruct.path;
            var _name = _resourceStruct.name;
            
            if (string_copy(_path, 1, 6) == "notes/")
            {
                if (variable_struct_exists(global.__dynamoNoteDictionary, _name))
                {
                    __DynamoTrace("Warning! Already found \"", _name, "\"");
                }
                else
                {
                    _path = _directory + _path;
                    
                    //Discover if this asset has a "dynamo ignore" tag
                    var _yyPath = filename_change_ext(_path, ".yy");
                    var _yyBuffer = buffer_load(_yyPath);
                    var _yyString = buffer_read(_yyBuffer, buffer_string);
                    buffer_delete(_yyBuffer);
                    
                    var _ignore = false;
                    var _yyJSON = json_parse(_yyString);
                    var _tagsArray = _yyJSON[$ "tags"];
                    if (is_array(_tagsArray))
                    {
                        var _j = 0;
                        repeat(array_length(_tagsArray))
                        {
                            var _tag = string_lower(_tagsArray[_j]);
                            if (_tag == "dynamo ignore")
                            {
                                _ignore = true;
                                break;
                            }
                            
                            ++_j;
                        }
                    }
                    
                    if (_ignore)
                    {
                        __DynamoTrace("Found note asset \"", _name, "\", but it has been set to ignored");
                    }
                    else
                    {
                        __DynamoTrace("Found note asset \"", _name, "\"");
                        array_push(_array, new __DynamoClassNote(_name, filename_change_ext(_path, ".txt"), undefined));
                    }
                }
            }
            
            ++_i;
        }
    }
    
    __DynamoTrace("Found ", array_length(_array), " note(s)");
    
    return _array;
}

function __DynamoManifestNotesArray(_path)
{
    global.__dynamoNoteDictionary = {};
    var _array = [];
    
    if (!file_exists(_path))
    {
        __DynamoError("Could not find manifest at \"", _path, "\"\nPlease ensure Dynamo has been set up by running dynamo.exe in the project's root directory");
        return;
    }
    
    __DynamoTrace("Loading manifest at \"", _path, "\"");
    
    var _directory = filename_dir(_path) + "\\";
    __DynamoTrace("Chose directory as \"", _directory, "\"");
    
    try
    {
        var _manifestBuffer = buffer_load(_path);
    }
    catch(_error)
    {
        __DynamoError("Failed to load manifest \"", _manifestBuffer, "\"");
        return;
    }
    
    var _header = buffer_read(_manifestBuffer, buffer_string);
    if (_header != "Dynamo")
    {
        __DynamoError("Header string incorrect, manifest may be corrupted\nFound \"", _header, "\"\nExpecting \"Dynamo\"");
        return;
    }
    
    var _version = buffer_read(_manifestBuffer, buffer_string);
    if (_version != __DYNAMO_VERSION)
    {
        __DynamoError("Version mismatch. Please re-export binaries\nFound \"", _version, "\"\nExpecting \"", __DYNAMO_VERSION, "\"");
        return;
    }
    
    var _count = buffer_read(_manifestBuffer, buffer_u64);
    __DynamoTrace("Manifest has ", _count, " note(s)");
    
    repeat(_count)
    {
        var _nameHash = buffer_read(_manifestBuffer, buffer_string);
        __DynamoTrace("Found name hash \"", _nameHash, "\"");
        
        var _note = new __DynamoClassNote(undefined, _directory + _nameHash + ".dynamo", _nameHash);
        array_push(_array, _note);
    }
    
    __DynamoTrace("Parsed manifest");
    
    return _array;
}

function __DynamoClassNote(_name, _sourcePath, _nameHash) constructor
{
    __name       = _name;
    __nameHash   = (_nameHash == undefined)? __DynamoNameHash(__name) : _nameHash;
    __sourcePath = _sourcePath;
    __dataHash   = undefined;
    
    global.__dynamoNoteDictionary[$ __nameHash] = self;
    
    static __HashInitialize = function()
    {
        if (__dataHash == undefined)
        {
            __dataHash = md5_file(__sourcePath);
            __DynamoTrace("\"", __name, "\" hash = \"", __dataHash, "\" (", __sourcePath, ")");
        }
    }
    
    static __CheckForChange = function()
    {
        var _newHash = md5_file(__sourcePath);
        __DynamoTrace("\"", __name, "\" new hash = \"", _newHash, "\" vs. old hash = \"", __dataHash, "\" (", __sourcePath, ")");
        
        if (_newHash != __dataHash)
        {
            __DynamoTrace("\"", __name, "\" changed");
            __dataHash = _newHash;
            
            return true;
        }
        else
        {
            __DynamoTrace("\"", __name, "\" did not change");
        }
        
        return false;
    }
    
    static __Export = function(_outputDirectory)
    {
        //Save out this asset to the target datafiles folder
        if (file_exists(__sourcePath))
        {
            var _txtBuffer = buffer_load(__sourcePath);
        }
        else
        {
            var _txtBuffer = buffer_create(1, buffer_fixed, 1);
        }
        
        var _outputPath = _outputDirectory + __nameHash + ".dynamo";
        __DynamoBufferSave(_txtBuffer, _outputPath);
        __DynamoTrace("Saved \"", __name, "\" to \"", _outputPath + "\"");
    }
}
