require "ingen"
require "lv2"

-- synth = { osc = lv2["sinCos"], filter = lv2["lpf/mono"] }; synth.filter.ports["in"].wires = { synth.osc.ports.sine }

s = ingen()
s.osc = lv2["SubSynth"]
s.wires["system:playback_1"] = { s.osc.ports.right }
s.wires["system:playback_2"] = { s.osc.ports.left }

s:run()