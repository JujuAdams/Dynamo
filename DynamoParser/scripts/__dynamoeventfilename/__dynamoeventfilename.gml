function __DynamoEventFilename(_eventType, _eventNumber)
{
    var _string = undefined;

    switch(_eventType)
    {
        case 0: _string = "Create"; break;
        case 3: _string = "Step";   break;
        case 8: _string = "Draw";   break;
    
        default:
           __DynamoError("Did not recognise event type ", _eventType);
        break;
    }

    return _string + "_" + string(_eventNumber);
}