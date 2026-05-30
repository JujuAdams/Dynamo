// Feather disable all

function __DynamoState()
{
    __DynamoInitialize();
    
    static _struct = {
        __scriptArray:   [],
        __scriptStruct:  {},
        __fileArray:     [],
        __fileStruct:    {},
        __trackingArray: [],
        
        __globalTokenStruct: {},
    };
    
    return _struct;
}
