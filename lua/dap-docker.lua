local M = {}

local default_config = {
	docker = {
		path = "docker",
		standalone = false,
	},
}

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	assert(ok, string.format("dap-docker dependency error: %s not installed", module_name))
	return module
end

local function get_arguments()
	return coroutine.create(function(dap_run_co)
		local args = {}
		vim.ui.input({ prompt = "Args: " }, function(input)
			args = vim.split(input or "", " ")
			coroutine.resume(dap_run_co, args)
		end)
	end)
end

local function get_build_target()
	return coroutine.create(function(dap_run_co)
		vim.ui.input({ prompt = "Target: " }, function(input)
			coroutine.resume(dap_run_co, input)
		end)
	end)
end

local function setup_dockerfile_adapter(dap, config)
	dap.adapters.dockerfile = function(callback, client_config)
		assert(client_config.request == "launch")

		local envmap = vim.tbl_extend("force", vim.fn.environ(), {
			BUILDX_EXPERIMENTAL = "1",
			BUILDX_DAP_USER_AGENT = "nvim/dap-docker",
		})

		local args = {}
		if not config.docker.standalone then
			vim.list_extend(args, { "buildx" })
		end
		if client_config.builder then
			vim.list_extend(args, { "--builder", client_config.builder })
		end
		vim.list_extend(args, { "dap", "build" })
		if client_config.args then
			vim.list_extend(args, client_config.args)
		end

		local final_config = vim.deepcopy(client_config)
		final_config.type = "executable"
		final_config.command = config.docker.path
		final_config.args = args
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

local function setup_dockerfile_configuration(dap, configs)
	local common_debug_configs = {
		{
			type = "dockerfile",
			name = "Build",
			request = "launch",
			dockerfile = "${file}",
			contextPath = "${workspaceFolder}",
		},
		{
			type = "dockerfile",
			name = "Build (Target)",
			request = "launch",
			dockerfile = "${file}",
			contextPath = "${workspaceFolder}",
			target = get_build_target,
		},
		{
			type = "dockerfile",
			name = "Build (Arguments)",
			request = "launch",
			dockerfile = "${file}",
			contextPath = "${workspaceFolder}",
			args = get_arguments,
		},
		{
			type = "dockerfile",
			name = "Build (Target & Arguments)",
			request = "launch",
			dockerfile = "${file}",
			contextPath = "${workspaceFolder}",
			target = get_build_target,
			args = get_arguments,
		},
	}

	if dap.configurations.dockerfile == nil then
		dap.configurations.dockerfile = {}
	end

	for _, config in ipairs(common_debug_configs) do
		table.insert(dap.configurations.dockerfile, config)
	end

	if configs == nil or configs.dap_configurations == nil then
		return
	end

	for _, config in ipairs(configs.dap_configurations) do
		if config.type == "dockerfile" then
			table.insert(dap.configurations.dockerfile, config)
		end
	end
end

function M.setup(opts)
	local internal_global_config = vim.tbl_deep_extend("force", default_config, opts or {})
	local dap = load_module("dap")
	setup_dockerfile_adapter(dap, internal_global_config)
	setup_dockerfile_configuration(dap)
end

return M
