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
		local p = { "ingen", "-e", "-n", "ingen"}
		-- p.stdout = subprocess.PIPE
		p.stderr = subprocess.stdout
		local engine = subprocess.popen(p)
		--outlines = engine.stdout:lines()
		sleep(4)
		-- create nodes first
		for k, object  in pairs(s) do
			if nil ~= object.uri then
				object.key_for_port_lookup = k
				local cmd = ingen_cmd .. " put /" .. k .. " 'a ingen:Node ; ingen:prototype <" .. object.uri ..">'"
				print("executing " .. cmd)
				
				os.execute(cmd)
				sleep(0.01)

				--[[
				os.execute(ingen_cmd .. " put /left_in 'a lv2:InputPort ; a lv2:AudioPort'")
				sleep(0.01)

				os.execute(ingen_cmd .. " put /left_out 'a lv2:OutputPort ; a lv2:AudioPort'")
				sleep(0.01)
		]]--
			end
		end
		
		-- connections second
		if nil ~= s.wires then
			for k, o in pairs(s.wires) do
				local index = 0
				if type(k) == type("string") then
					-- create an ingen output port
					os.execute(ingen_cmd .. " put /ingen_synth_ 'a lv2:OutputPort ; a lv2:AudioPort'")
					-- os.execute("jack_connect ingen:ingen_synth_" .. index .. " " .. k)
					sleep(0.01)
				else
					--[[
					local cmd = ingen_cmd .. " connect /" .. k.plugin.key_for_port_lookup .. "/" .. k.symbol .. " " .. " /" .. o.plugin.key_for_port_lookup .. "/" .. o.symbol
					print("executing " .. cmd)
					
					os.execute(cmd)
					sleep(0.01)
					
					local cmd = ingen_cmd .. " connect /" .. k.plugin.key_for_port_lookup .. "/" .. k.symbol .. " /left_out"
					print("executing " .. cmd)
					
					os.execute(cmd)
					sleep(0.01)
		]]--
				end

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