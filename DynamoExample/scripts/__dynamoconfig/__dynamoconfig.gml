//Whether to allow Dynamo's live updating features to operate
//You should set this to <false> when releasing builds
#macro DYNAMO_ENABLED  true

//Whether to show extended debug information in the debug log
//This can be useful to track down problems when using Dynamo
#macro DYNAMO_VERBOSE  false

//The name of the tag that Dynamo will look for in your project to identify live update scripts
//Change this name if you'd like to tag your assets in some other way
#macro DYNAMO_TRACK_TAG  "dynamo"