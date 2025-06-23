local M = {}

local default_config = {
	docker = {
		path = "docker",
	},
}

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	assert(ok, string.format("dap-docker dependency error: %s not installed", module_name))
	return module
end

local function setup_dockerfile_adapter(dap, config)
	dap.adapters.dockerfile = function(callback, client_config)
		assert(client_config.request == "launch")

		local envmap = vim.tbl_extend("force", vim.fn.environ(), {
			BUILDX_EXPERIMENTAL = "1",
		})
		local final_config = vim.deepcopy(client_config)
		final_config.type = "executable"
		final_config.command = config.docker.path
		final_config.args = { "buildx", "dap", "build" }
		final_config.options = {
			env = vim.iter(envmap)
				:map(function(k, v)
					return k .. "=" .. v
				end)
				:totable(),
		}
		callback(final_config)
	end
end

local function setup_dockerfile_configuration(dap)
	local common_debug_config = {
		{
			type = "dockerfile",
			name = "Build Dockerfile",
			request = "launch",
			dockerfile = "${file}",
			contextPath = "${workspaceFolder}",
		},
	}

	if dap.configurations.dockerfile == nil then
		dap.configurations.dockerfile = {}
	end

	for _, config in ipairs(common_debug_config) do
		table.insert(dap.configurations.dockerfile, config)
	end
end

function M.setup(opts)
	local internal_global_config = vim.tbl_deep_extend("force", default_config, opts or {})
	local dap = load_module("dap")
	setup_dockerfile_adapter(dap, internal_global_config)
	setup_dockerfile_configuration(dap)
end

return M
