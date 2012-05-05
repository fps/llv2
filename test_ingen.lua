require "ingen"
require "lv2"

s = ingen("foo")

s.osc = lv2["sinCos"]
s.flanger = lv2["djFlanger"]

s.wires["system:playback_1"] = { s.osc.ports.sine }
s.wires["system:playback_2"] = { s.osc.ports.cosine }
s.wires[s.flanger.ports.input] = s.osc.ports.sine
s:run()