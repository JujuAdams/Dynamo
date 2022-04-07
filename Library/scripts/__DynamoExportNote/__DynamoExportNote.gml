function __DynamoExportNote(_noteInstance, _outputDirectory)
{
    with(_noteInstance)
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
        buffer_save(_txtBuffer, _outputPath);
        __DynamoTrace("Saved \"", __name, "\" to \"", _outputPath + "\"");
    }
}