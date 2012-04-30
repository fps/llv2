require "llilv"

local as_string = 
	function(node)
		return llilv.lilv_node_as_string(node)
	end


-- add ports to a plugin
local setup_ports = 
	function(p, plugin)
		local ports = {}
		local mt = {}
		
		-- a metatable to make port lookup easier
		mt.__index = 
			function(key)
			end

		for index = 0, llilv.lilv_plugin_get_num_ports(plugin) - 1 , 1 do
			-- print ("index: " .. index)
			local port = llilv.lilv_plugin_get_port_by_index(plugin, index)
			local symbol = as_string(llilv.lilv_port_get_symbol(plugin, port))

			ports[symbol] = {}
			ports[symbol].port = port

			ports[symbol].name = as_string(llilv.lilv_port_get_name(plugin, port))
			ports[symbol].classes = {}

			local classes = llilv.lilv_port_get_classes(plugin, port)
			local classes_iter = llilv.lilv_nodes_begin(classes)
			index = 1
			while false == llilv.lilv_nodes_is_end(classes, classes_iter) do
				-- print ("class: " .. llilv.lilv_node_as_uri(llilv.lilv_nodes_get(classes, classes_iter)))
				ports[symbol].classes[index] = llilv.lilv_node_as_uri(llilv.lilv_nodes_get(classes, classes_iter))
				index = index + 1
				classes_iter = llilv.lilv_nodes_next(classes, classes_iter)
			end
		end
		p.ports = ports
	end

-- create a proxy for the plugin
local setup_plugin = 
	function(plugin)
		local p = {}

		p.plugin = plugin
		p.uri = as_string(llilv.lilv_plugin_get_uri(plugin)) 
		-- p.path = llilv.lilv_uri_to_path(p.uri)
		p.name = as_string(llilv.lilv_plugin_get_name(plugin))
		p.class = as_string(llilv.lilv_plugin_class_get_label(llilv.lilv_plugin_get_class(plugin)))
		setup_ports(p, plugin)

		_G.lv2[p.uri] = p
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