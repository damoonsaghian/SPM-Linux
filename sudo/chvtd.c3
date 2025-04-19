/*
a service that monitors key presses using libinput
and if Fn (F1-F8) are pressed:
, if in VT1, go to VT2 if a program is running there, otherwise go to VT3 and run bash as user 1000
, if in VT2, kill any running program in VT2, go to previous terminal
, if in VT3, go to VT2 if a program is running there, otherwise go to VT1
*/
