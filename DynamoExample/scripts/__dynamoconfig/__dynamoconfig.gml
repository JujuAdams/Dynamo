//Whether to allow Dynamo's live updating features to operate
//You should set this to <false> when releasing builds
#macro DYNAMO_ENABLED  true

#macro DYNAMO_AUTO_SCAN  true

//Whether to progressively scan through tracked data looking for changes
//The alternative is for Dynamo to only scan for changes when the window regains focus
//This macro is forced to <true> on MacOS due to bugs in GameMaker
#macro DYNAMO_PROGRESSIVE_SCAN  false

//Whether to show extended debug information in the debug log
//This can be useful to track down problems when using Dynamo
#macro DYNAMO_VERBOSE  true

#macro DYNAMO_DYNAMIC_VARIABLES  true