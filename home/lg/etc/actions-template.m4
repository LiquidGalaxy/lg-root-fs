# viewsyncrelay config file
---
# Each input has a name, a port, and a bind address. It accepts UDP traffic on that port
# XXX Make this support receiving multicast
input_streams:
    -
        name: input
        port: 45677
        addr: 0.0.0.0

# Each output has a name, an address, and a port, and sends UDP traffic on that
# port. The broadcast element can be true, false, or missing; if it's missing,
# it will be the equivalent of "false". This tells the script whether this is a
# broadcast address or not.
# XXX Make this support sending multicast, broadcast
output_streams:
    -
        name: output
        host: 10.42.42.255
        port: 45678
        broadcast: true

# Linkages connect inputs and outputs, optionally including transformations.
# Inputs and outputs are both names referring to input streams, and can be a
# scalar or an array. Transform can also contain a scalar or array, indicating
# transformations applied in the order given
# XXX Actually implement the "scalar or array" stuff for input, output, and transform
linkages:
    -
        name: normal input
        input: input
        output: output

# Actions tell viewsyncrelay to do something when a packet matches some conditions
# "repeat" values can be:
#   DEFAULT:
#       Run the first time a packet matches conditions. Don't run again until
#       after we get a packet that *doesn't* match the constraints
#   ALL: Run each time a packet matches thesse constraints
#   ONCE: Run once (duh!)
#   RESET: Allows a reset_constraints section exactly like the constraints
#       section. Runs the action once, but resets when the reset_constraints
#       are matched, allowing the action to run again. These actions also allow
#       an "initially_disabled" field, which, when set, means the action needs
#       to be reset *before* it can run at all. Note that the presence of the
#       initially_disabled key is sufficient to make it disabled; the value of
#       the key doesn't matter.
actions:
    -
        name: play triosonata
        input: ALL
        action: mplayer -really-quiet -fs -zoom p1.flv
        exit_action: mp-control 
        repeat: DEFAULT
        constraints:
            latitude: '(10.0, 20.0]'
            longitude: '[10.0, 20.0]'
