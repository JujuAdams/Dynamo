/// @param projectJSON
/// @param directory
/// @param platform
/// @param browser

function __DynamoProjectFindFiles(_projectJSON, _directory, _platform, _browser)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _outputArray = [];
    
    var _mask = 0;
    if (_browser != browser_not_a_browser)
    {
        _mask = 32;
    }
    else
    {
        switch(_platform)
        {
            //Who the ferducken chose these constants?!
            case os_macosx:       _mask =   2;                break;
            case os_ios:          _mask =   4;                break;
            case os_android:      _mask =   8;                break;
            case os_windows:      _mask =  64;                break;
            case os_linux:        _mask = 128;                break;
            case os_xboxseriesxs: _mask = 4294967296;         break;
            case os_operagx:      _mask = 17179869184;        break;
            case os_xboxone:      _mask = 34359738368;        break;
            case os_uwp:          _mask = 35184372088832;     break;
            case os_tvos:         _mask = 9007199254740992;   break;
            case os_switch:       _mask = 144115188075855872; break;
            case os_ps5:          _mask = 576460752303423488; break;
            
            default:
                __DynamoError("Unhandled platform (", _platform, ")");
            break;
        }
    }
    
    var _count = 0;
    var _filesArray = _projectJSON.IncludedFiles;
    var _i = 0;
    repeat(array_length(_filesArray))
    {
        var _fileStruct = _filesArray[_i];
        var _copyToMask = _fileStruct.CopyToMask;
        
        if ((_copyToMask < 0) || (_mask & _copyToMask > 0))
        {
            array_push(_outputArray, new __DynamoClassFile(_directory, _fileStruct.filePath + "/" + _fileStruct.name));
            ++_count;
        }
        
        ++_i;
    }
    
    if (DYNAMO_VERBOSE) __DynamoTrace("Found ", _count, " files exported for this platform");
    
    return _outputArray;
}