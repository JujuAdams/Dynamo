// Whether to run Dynamo in dev mode
// Running in dev mode allows three things to happen:
//   - Dynamo will read Note files directly from your project directory instead of the exported .dynamo files
//   - DynamoDevCheckForChanges() and DynamoDevCheckForChangesOnRefocus() are enabled
//   - Live reload of Note assets is possible
//   - Some errors (such as missing files) are changed to softer warnings to make live reload less irritating
// 
// Dev mode is forced off when exporting production builds, but for the sake of
// safety, it is recommended that you also set DYNAMO_DEV_MODE to <false>. At
// any rate, when testing production builds before release, set DYNAMO_DEV_MODE
// to <false> to force Dynamo to use the exported .dynamo files that represent
// your Note assets. This is how Dynamo will behave in production and you should
// test under those conditions before release!
#macro DYNAMO_DEV_MODE  true
