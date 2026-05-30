// Feather disable all

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//    Customisation options can be found in the Configuration scripts.    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

#macro DYNAMO_VERSION  "5.0.0"
#macro DYNAMO_DATE     "2026-05-30"

#macro DYNAMO_RUNNING              (DYNAMO_ENABLED && (GM_build_type == "run") && ((os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)))
#macro DYNAMO_PROJECT_DIRECTORY    (DYNAMO_RUNNING? (filename_dir(GM_project_filename) + "/") : "")
#macro DYNAMO_DATAFILES_DIRECTORY  (DYNAMO_RUNNING? (DYNAMO_PROJECT_DIRECTORY + "datafiles/") : "")