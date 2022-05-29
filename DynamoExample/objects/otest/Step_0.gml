if (keyboard_check_pressed(ord("M"))) audio_play_sound(sndTest, 1, false);

if (!audio_is_playing(sndTest)) audio_play_sound(sndTest, 1, false);