function __DynamoClassSound(_path) constructor
{
    static __type = __DYNAMO_TYPE_SCRIPT;
    
    __metadataPath = _path;
    __metadataStub = true;
    __metadataHash = undefined;
    
    __json = {};
    __volume = undefined;
    
    static __Track = function()
    {
        if (!__MetadataEnsure()) return;
        
        var _name = __GetName();
        array_push(global.__dynamoTrackingArray, _name);
        global.__dynamoTrackingStruct[$ _name] = self;
    }
    
    static __MetadataEnsure = function(_dontCheckHash = true)
    {
        var _foundHash = (_dontCheckHash && (__metadataHash != undefined) && !__metadataStub)? __metadataHash : __DynamoFileHash(__metadataPath);
        if (_foundHash != __metadataHash)
        {
            __metadataHash = _foundHash;
            
            __json = __DynamoLoadJSON(__metadataPath, undefined);
            if (is_struct(__json))
            {
                __metadataStub = false;
                __volume = __json.volume;
            }
        }
        
        return is_struct(__json);
    }
    
    static __TagAnyMatches = function(_tag)
    {
        if (!__MetadataEnsure()) return false;
        
        var _tagArray = __json.tags;
        var _i = 0;
        repeat(array_length(_tagArray))
        {
            if (_tagArray[_i] == _tag) return true;
            ++_i;
        }
        
        return false;
    }
    
    static __ContentCheckForChanges = function()
    {
        if (!__MetadataEnsure()) return false;
        return (__DynamoFileHash(__metadataPath) != __metadataHash);
    }
    static __Apply = function()
    {
        if (!__MetadataEnsure(false)) return false;
        
        var _asset = asset_get_index(__GetName());
        if (_asset < 0) return false;
        
        audio_sound_gain(_asset, __json.volume, 0);
        return true;
    }
    
    static __GetName = function()
    {
        if (!__MetadataEnsure()) return "<unknown sound>";
        return __json.name;
    }
    
    static toString = function()
    {
        return __GetName();
    }
}