var _changes = undefined;

if (keyboard_check_pressed(vk_f5))
{
    //Force a refresh on F5
    _changes = DynamoDevCheckForChanges();
}
else
{
    //Otherwise check for changes whenever the game regains focus
    _changes = DynamoDevCheckForChangesOnRefocus();
}

if (is_array(_changes))
{
    //Normally you'd check to see what's changed but we can be lazy here
    simpleNoteContent = DynamoNoteString("ExampleSimpleNote");
    funcImportSoundSettings(DynamoNoteString("ExampleSoundSettings"));
    funcImportExternalTextFile();
}

//sndOw
if (keyboard_check_pressed(ord("1")))
{
    var _gain  = 1.0;
    var _pitch = 1.0;
    
    //We can't be sure if we have valid JSON data so let's wrap the getters in a try...catch
    try
    {
        _gain  = soundSettings.sndOw.gain;
        _pitch = soundSettings.sndOw.pitch;
    }
    catch(_error)
    {
        show_debug_message("Error whilst trying to play sndOw (" + string(_error) + ")");
    }
    
    var _instance = audio_play_sound(sndOw, 0, false);
    audio_sound_gain(_instance, _gain, 0);
    audio_sound_pitch(_instance, _pitch);
}

//sndPing
if (keyboard_check_pressed(ord("2")))
{
    var _gain  = 1.0;
    var _pitch = 1.0;
    
    //We can't be sure if we have valid JSON data so let's wrap the getters in a try...catch
    try
    {
        _gain  = soundSettings.sndPing.gain;
        _pitch = soundSettings.sndPing.pitch;
    }
    catch(_error)
    {
        show_debug_message("Error whilst trying to play sndPing (" + string(_error) + ")");
    }
    
    var _instance = audio_play_sound(sndPing, 0, false);
    audio_sound_gain(_instance, _gain, 0);
    audio_sound_pitch(_instance, _pitch);
}

if (keyboard_check_pressed(ord("Q")))
{
    DynamoDevSaveString("hello!", "datafileSaveTest.txt");
}

if (keyboard_check_pressed(ord("W")))
{
    DynamoDevSaveNoteString("editing a note, shocking!", "ExampleEmptyNote");
}
