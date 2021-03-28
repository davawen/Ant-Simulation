globalvar console;

console = {};

console.log = function(message/*: any*/)/*->void*/
{
    show_debug_message(message);
}

/// @hint console()->string[]
/// @hint console.log(message: any)->void