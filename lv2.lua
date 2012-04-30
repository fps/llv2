require "llilv"

local world = llilv.lilv_world_new()
llilv.lilv_world_load_all(world)

local plugins = llilv.lilv_world_get_all_plugins(world)
local iter = llilv.lilv_plugins_begin(plugins)

_G.lv2 = {}

local as_string = function(node)
	return llilv.lilv_node_as_string(node)
end

while false == llilv.lilv_plugins_is_end(plugins, iter) do
	plugin = llilv.lilv_plugins_get(plugins, iter)
	local uri = as_string(llilv.lilv_plugin_get_uri(plugin))

	lv2[uri] = {}
	lv2[uri].name = as_string(llilv.lilv_plugin_get_name(plugin))
	lv2[uri].class = llilv.lilv_node_as_string(llilv.lilv_plugin_class_get_label(llilv.lilv_plugin_get_class(plugin)))

	lv2[uri].ports = {}
	for index = 0, llilv.lilv_plugin_get_num_ports(plugin) - 1 , 1 do
		-- print ("index: " .. index)
		lv2[uri].ports[index + 1] = {}
		local port = llilv.lilv_plugin_get_port_by_index(plugin, index)
		lv2[uri].ports[index + 1].name = llilv.lilv_node_as_string(llilv.lilv_port_get_name(plugin, port))
		lv2[uri].ports[index + 1].classes = {}
				
	end

	iter = llilv.lilv_plugins_next(plugins, iter)
end

local mt = {}
mt.__index = function(table, key)
	-- return the first match
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