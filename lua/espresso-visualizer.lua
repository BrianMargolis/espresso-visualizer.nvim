local M = {}

M.curl = nil
M.config = {
	profile = "",
	debug_response_in_buffer = false,
}
function M._get_last_shot()
	if not M.curl then
		print("curl not found! maybe you forget to call setup()")
		return
	end
	if not M.config.profile then
		print("no profile set!")
		return
	end

	local url = "https://visualizer.coffee/people/" .. M.config.profile
	local response = M.curl.get(url)

	if not response or not response.body then
		print("failed to fetch: " .. url)
		return
	end

	if M.config.debug_response_in_buffer then
		local tmp_buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, vim.split(response.body, "\n"))
	end

	-- find the first instance of 'id="shots-table"'
	local search_start = string.find(response.body, "shots-table", 1, true)
	if not search_start then
		print("failed to find shots table")
		return
	end

	-- from that point, find the next occurence of data-url, and capture the text
	-- in the following set of quotes
	local shot_url_start = string.find(response.body, 'data-url="', search_start, true)
	if not shot_url_start then
		print("failed to find start of data-url")
		return
	end
	shot_url_start = shot_url_start + 10
	local shot_url_end = string.find(response.body, '"', shot_url_start, true)
	if not shot_url_end then
		print("failed to find end of data-url")
		return
	end
	local shot_url = string.sub(response.body, shot_url_start, shot_url_end - 1)
	return "https://visualizer.coffee" .. shot_url
end

function M.append_last_shot(opts)
	local shot_url = M._get_last_shot()
	if not shot_url then
		print("failed to get shot url")
		return
	end

	if opts.decorator then
		shot_url = opts.decorator(shot_url)
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	vim.api.nvim_set_current_line(line .. " " .. shot_url)
	vim.api.nvim_win_set_cursor(0, { row, col + #shot_url })
end

function M.open_last_shot()
	local shot_url = M._get_last_shot()
	if not shot_url then
		print("failed to get shot url")
		return
	end
	vim.cmd("silent! !open " .. shot_url)
end

function M.setup(config)
	M.config = vim.tbl_extend("force", M.config, config or {})

	local curl_ok, curl = pcall(require, "plenary.curl")
	if not curl_ok then
		print("plenary.curl not found! Please install it")
		return
	end
	M.curl = curl
end

return M
