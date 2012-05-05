require "ingen"
require "lv2"

s = ingen("foo")

s.osc = lv2["SubSynth"]
s.flanger = lv2["djFlanger"]

s.wires["system:playback_1"] = { s.osc.ports.out1 }
s.wires["system:playback_2"] = { s.osc.ports.out2 }
s.wires[s.flanger.ports.input] = s.osc.ports.out2
s:run()