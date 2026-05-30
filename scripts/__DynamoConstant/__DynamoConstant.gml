// Feather disable all

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//    Customisation options can be found in the Configuration scripts.    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

#macro DYNAMO_VERSION  "4.0.2"
#macro DYNAMO_DATE     "2024-08-18"

#macro DYNAMO_RUNNING  (DYNAMO_ENABLED && (GM_build_type == "run") && ((os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)))