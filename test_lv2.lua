require("lv2")

-- create a synth spec
s = {}
s.osc = lv2["sinCos"]
s.filter = lv2["lpf/mono"]
s.wires = {}
s.wires[s.filter.ports["in"]] = s.osc.ports.sine
