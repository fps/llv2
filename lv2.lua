require "llilv"

local as_string = 
	function(node)
		return llilv.lilv_node_as_string(node)
	end


-- add ports to a plugin
local setup_ports = 
	function(p, plugin)
		p.ports = {}

		for index = 0, llilv.lilv_plugin_get_num_ports(plugin) - 1 , 1 do
			-- print ("index: " .. index)
			p.ports[index + 1] = {}
			local port = llilv.lilv_plugin_get_port_by_index(plugin, index)
			p.ports[index + 1].name = as_string(llilv.lilv_port_get_name(plugin, port))
			p.ports[index + 1].classes = {}
		end
	end

-- create a proxy for the plugin
local setup_plugin = 
	function(plugin)
		local p = {}
		p.plugin = plugin
		p.uri = as_string(llilv.lilv_plugin_get_uri(plugin)) 
		print ("setting up: " .. p.uri)
		_G.lv2[p.uri] = p
		p.name = as_string(llilv.lilv_plugin_get_name(plugin))
		p.class = as_string(llilv.lilv_plugin_class_get_label(llilv.lilv_plugin_get_class(plugin)))
		setup_ports(p, plugin)
		return p
	end

local setup_plugins = 
	function() 
		_G.lv2 = {}

		local world = llilv.lilv_world_new()
		llilv.lilv_world_load_all(world)
		local plugins = llilv.lilv_world_get_all_plugins(world)
		local iter = llilv.lilv_plugins_begin(plugins)

		while false == llilv.lilv_plugins_is_end(plugins, iter) do
			local plugin = llilv.lilv_plugins_get(plugins, iter)
			print ("setting up plugin")
			setup_plugin(plugin)

			iter = llilv.lilv_plugins_next(plugins, iter)
		end
	end

setup_plugins()

local mt = {}
mt.__index = 
	function(table, key)
		-- return the first URI match
		for i,v in pairs(lv2) do
			local match = string.find(i, key)
			if nil ~= match then
				print ("match: " .. i)
				return lv2[i]
			end
		end
		return nil
	end
setmetatable(lv2, mt)