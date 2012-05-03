require("lv2")

print ("iterate over lv2 with " ..  # lv2 .. " elements")

for i,v in pairs(lv2.plugins) do
	print (i) 
	print ("  name: " .. v.name)
	print ("  class: " .. v.class) 

	for j,w in pairs(v.ports) do
		print ("    " .. j .. ":") 
		print ("      " .. " name: " .. w.name)

		for k,x in ipairs(w.classes) do
			print ("        " .. " class " .. k .. ": "  .. x)
		end
	end
end
