Section "InputDevice"
    Identifier     "dummy"
    Driver         "void"
    Option         "Device" "/dev/input/mice"
EndSection

__EVENT_MOUSE_BLOCK__

Section "InputDevice"
    Identifier      "Quanta Touch"
    Driver          "evdev"
    Option          "Device"                "/dev/input/quanta_touch"
    Option          "SendCoreEvents"        "true"
EndSection

