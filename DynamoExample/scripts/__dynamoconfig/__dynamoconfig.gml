//Whether to allow Dynamo's live updating features to operate
//You should set this to <false> when releasing builds
#macro DYNAMO_ENABLED  true

//Whether to progressively scan through tracked data looking for changes
//The alternative is for Dynamo to only scan for changes when the window regains focus
//This macro is forced to <true> on MacOS due to bugs in GameMaker
#macro DYNAMO_PROGRESSIVE_SCAN  false

//Whether to show extended debug information in the debug log
//This can be useful to track down problems when using Dynamo
#macro DYNAMO_VERBOSE  false

//Whether to require the use of "dynamo" tag for a sound's volume to be tracked by Dynamo
//If this is set to <false> then all sound volumes will be tracked
//You can opt out by adding the "dynamo skip" tag to sound assets you don't wish to track
#macro DYNAMO_OPT_IN_SOUNDS  false

#macro DYNAMO_DYNAMIC_VARIABLES  true

//The name of the tag that Dynamo will look for in your project to identify assets to live update
//Change this name if you'd like to tag your assets in some other way
#macro DYNAMO_TRACK_TAG  "dynamo"

//The name of the tag that Dynamo will look for to ignore assets that would otherwise be tracked
//Change this name if you'd like to tag your assets in some other way
#macro DYNAMO_REJECT_TAG  "dynamo skip"