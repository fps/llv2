require "subprocess"
require "os"
require "io"
require "socket"

local sleep = 
	function (sec)
		socket.select(nil, nil, sec)
	end

local ingen_cmd = "ingenish" 

local run = 
	function(s)
		os.execute("rm /tmp/ingen.sock")
		local p = { "ingen", "-eg", "-n", "ingen"}
		-- p.stdout = subprocess.PIPE
		p.stderr = subprocess.stdout
		local engine = subprocess.popen(p)
		--outlines = engine.stdout:lines()
		sleep(2)
		-- create nodes first
		for k, object  in pairs(s) do
			if nil ~= object.uri then
				object.key_for_port_lookup = k
				local cmd = ingen_cmd .. " put /" .. k .. " 'a ingen:Node ; ingen:prototype <" .. object.uri ..">'"

				print("executing " .. cmd)
				os.execute(cmd)
				sleep(0.1)
			end
		end
		
		-- connections second
		if nil ~= s.wires then
			local index = 0
			for k, o in pairs(s.wires) do

				if type(k) == type("string") then
					print("string: " .. k  .. " " .. # o)

					-- do we have at least one wire?
					if 0 ~= # o then
						m = o[1]
						if nil ~= string.find(m.classes, "http://lv2plug.in/ns/lv2core#InputPort") then
							-- output
							if nil ~= string.find(m.classes, "http://lv2plug.in/ns/lv2core#AudioPort") then
								os.execute(ingen_cmd .. " put /ingen_synth_" .. index .. " 'a lv2:InputPort ; a lv2:AudioPort'")
								sleep(0.1)
							end
							if nil ~= string.find(m.classes, "http://lv2plug.in/ns/lv2core#ControlPort") then
								os.execute(ingen_cmd .. " put /ingen_synth_" .. index .. " 'a lv2:InputPort ; a lv2:ControlPort'")
								sleep(0.1)
							end

							print("classes: " .. m.classes)
							os.execute(ingen_cmd .. " connect "  .. " /ingen_synth_" .. index .. " /" .. m.plugin.key_for_port_lookup .. "/" .. m.symbol)
							sleep(0.1)
						else
							-- input
							if nil ~= string.find(m.classes, "http://lv2plug.in/ns/lv2core#AudioPort") then
								os.execute(ingen_cmd .. " put /ingen_synth_" .. index .. " 'a lv2:OutputPort ; a lv2:AudioPort'")
								sleep(0.1)
							end
							if nil ~= string.find(m.classes, "http://lv2plug.in/ns/lv2core#ControlPort") then
								os.execute(ingen_cmd .. " put /ingen_synth_" .. index .. " 'a lv2:OutputPort ; a lv2:ControlPort'")
								sleep(0.1)
							end

							print("classes: " .. m.classes)
							os.execute(ingen_cmd .. " connect " .. " /" .. m.plugin.key_for_port_lookup .. "/" .. m.symbol  .. " /ingen_synth_" .. index )
							sleep(0.1)
						end

						-- and finally hook it up vi jack_connect
						os.execute("jack_connect ingen:ingen_synth_" .. index .. " " .. k)
					end


					-- create an ingen output port
					-- os.execute("jack_connect ingen:ingen_synth_" .. index .. " " .. k)

				else -- this is not a string, so it will be an ingen node to an ingen node connection
					if nil ~= string.find(k.classes, "http://lv2plug.in/ns/lv2core#OutputPort") then
						local cmd = ingen_cmd .. " connect /" .. k.plugin.key_for_port_lookup .. "/" .. k.symbol .. " " .. " /" .. o.plugin.key_for_port_lookup .. "/" .. o.symbol
						print("executing " .. cmd)
						
						os.execute(cmd)
						sleep(0.1)
					else
						local cmd = ingen_cmd .. " connect " ..  " /" .. o.plugin.key_for_port_lookup .. "/" .. o.symbol ..  " /" .. k.plugin.key_for_port_lookup .. "/" .. k.symbol
						print("executing " .. cmd)
						
						os.execute(cmd)
						sleep(0.1)
					end
				end
				index = index + 1
			end
		end
		io.stdin:read'*l'

		engine:terminate()
		
		sleep(2)
	end

local stop =
	function(s)
		
	end

_G.ingen = 
	function()
		synth = {}

		local mt = {}
		mt.__index =
			function(s, key)
				if "run" == key then
					return run
				end
			end
		setmetatable(synth, mt)

		synth.wires = {}

		return synth
	end