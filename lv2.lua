require "llilv"
local deepcopy = 
	function (object)
		-- print("deepcopy: " .. object.uri)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
            return object
			elseif lookup_table[object] then
            return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
		end
		return _copy(object)
	end

local as_string = 
	function(node)
		return llilv.lilv_node_as_string(node)
	end


-- add ports to a plugin
local setup_ports = 
	function(p, plugin)
		local ports = {}

		for index = 0, llilv.lilv_plugin_get_num_ports(plugin) - 1 , 1 do
			-- print ("index: " .. index)
			local port = llilv.lilv_plugin_get_port_by_index(plugin, index)
			local symbol = as_string(llilv.lilv_port_get_symbol(plugin, port))

			ports[symbol] = {}
			ports[symbol].port = port
			ports[symbol].symbol = symbol
			ports[symbol].plugin = p
			ports[symbol].wires = {}

			ports[symbol].name = as_string(llilv.lilv_port_get_name(plugin, port))
			ports[symbol].classes = ""

			local mt = { __concat = function(left, right) left.wires = right end }
			setmetatable(ports[symbol], mt)
			local classes = llilv.lilv_port_get_classes(plugin, port)
			local classes_iter = llilv.lilv_nodes_begin(classes)
			local index = 1
			while false == llilv.lilv_nodes_is_end(classes, classes_iter) do
				-- print ("class: " .. llilv.lilv_node_as_uri(llilv.lilv_nodes_get(classes, classes_iter)))
				ports[symbol].classes = ports[symbol].classes .. " " .. llilv.lilv_node_as_uri(llilv.lilv_nodes_get(classes, classes_iter))
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

		_G.lv2.plugins[p.uri] = p
	end

local setup_plugins = 
	function() 
		_G.lv2 = {}
		_G.lv2.plugins = {}

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
		for i,v in pairs(lv2.plugins) do
			local match = string.find(i, key)
			if nil ~= match then
				return deepcopy(lv2.plugins[i])
			end
		end
		print("warning, no plugin found for key: " .. key)
		return nil
	end
setmetatable(lv2, mt)