require "ingen"
require "lv2"

s = ingen("foo")

s.osc = lv2["blip/sawtooth"]

s.wires["system:playback_1"] = { s.osc.ports.port1 }
s.wires["system:playback_2"] = { s.osc.ports.port1 }

s:run()