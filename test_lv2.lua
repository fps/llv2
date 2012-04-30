require("lv2")

print ("iterate over lv2 with " ..  # lv2 .. " elements")

for i,v in pairs(lv2) do
	print (i) 
	print ("  name: " .. v.name)
	print ("  class: " .. v.class) 
	print ("  num ports: " .. # v.ports)
	for port = 0, # v.ports - 1, 1 do
		print ("    name: " .. v.ports[port + 1].name)
	end
end

-- let's find a plugin with a partial URI - metatables make it possible
print(lv2.bandpass_iir.name)
