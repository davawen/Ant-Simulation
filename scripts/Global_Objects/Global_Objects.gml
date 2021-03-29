globalvar console;

console = {};

console.log = function(message/*: any*/)/*->void*/
{
    show_debug_message(message);
}

console.debugCount = 0;

/// @hint console()->string[]
/// @hint console.log(message: any)->void Print any message to the console
/// @hint console.debugCount: number