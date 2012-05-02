require "ingen"
require "lv2"

-- synth = { osc = lv2["sinCos"], filter = lv2["lpf/mono"] }; synth.filter.ports["in"].wires = { synth.osc.ports.sine }

s = ingen()
s.osc = lv2["sinCos"]
s.filter = lv2["lpf/mono"]
s.wires[s.osc.ports.sine] = s.filter.ports["in"]

s:run()