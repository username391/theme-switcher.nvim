-- this should be made via "telescope.register_extension" probably
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local action_set = require "telescope.actions.set"


Themer = {}


Themer.Themes = {
    { name = "Catppuccin Latte", cmd = "catppuccin-latte", background = "light" },
    { name = "Catppuccin Frappe", cmd = "catppuccin-frappe", background = "dark" },
    { name = "Catppuccin Macchiato", cmd = "catppuccin-macchiato", background = "dark" },
    { name = "Catppuccin Mocha", cmd = "catppuccin-mocha", background = "dark" },
    { name = "Dracula", cmd = "dracula", background="dark" },
    { name = "Kanagawa Dark", cmd = "kanagawa", background = "dark" },
    { name = "Kanagawa Light", cmd = "kanagawa", background = "light" },
    { name = "Monokai Pro", cmd = "monokai_pro", background = "dark" },
    { name = "Monokai Soda", cmd = "monokai_soda", background = "dark" },
    { name = "Monokai Ristretto", cmd = "monokai_ristretto", background = "dark" },
    { name = "Moonbow", cmd = "moonbow", background = "dark" },
    { name = "NightFly", cmd = "nightfly", background = "dark" },
    { name = "Nightly", cmd = "nightly", background = "dark" },
    { name = "OneDark", cmd = "onedark", background = "dark" },
    { name = "OneNord Dark", cmd = "onenord", background = "dark" },
    { name = "OneNord Light", cmd = "onenord", background = "light" },
    { name = "PalenightFall", cmd = "palenightfall", background = "dark" },
    { name = "TokyoNight Night", cmd = "tokyonight-night", background = "dark" },
    { name = "TokyoNight Storn", cmd = "tokyonight-storm", background = "dark" },
    { name = "TokyoNight Day ", cmd = "tokyonight-day", background = "light" },
    { name = "TokyoNight Moon", cmd = "tokyonight-moon", background = "dark" },
    { name = "VSCode Light", cmd = "vscode", background = "light" },
    { name = "VSCode Dark", cmd = "vscode", background = "dark" },
	{ name = "GitHub Dark", cmd = "github_dark", background = "dark" },
	{ name = "GitHub Dark Dimmed", cmd = "github_dark_dimmed", background = "dark" },
	{ name = "GitHub Dark High Contrast", cmd = "github_dark_high_contrast", background = "dark" },
	{ name = "GitHub Dark Colorblind", cmd = "github_dark_colorblind", backgrond = "dark"},
	{ name = "GitHub Dark Tritanopia", cmd = "github_dark_tritanopia", background = "dark" },
	{ name = "GitHub Light", cmd = "github_light", background = "light" },
	{ name = "GitHub Light High Contrast", cmd = "github_light_high_contrast", background = "light" },
	{ name = "GitHub Light Colorblind", cmd = "github_light_colorblind", background = "light" },
	{ name = "GitHub Light Tritanopia", cmd = "github_light_tritanopia", background = "light" },
	{ name = 'Rose Pine', cmd = 'rose-pine', background = 'dark' },
	{ name = 'Rose Pine Light', cmd = 'rose-pine', background = 'light'}
}


Themer.SelectDefault = function(_)
	local selection = action_state.get_selected_entry()
	Themer.SetTheme(Themer.Themes[selection.index], true)
end


Themer.ShiftSelection = function(prompt_bufnr, change)
	local count = vim.v.count

	count = count == 0 and 1 or count -- ?
	count = vim.api.nvim_get_mode().mode == "n" and count or 1
	action_state.get_current_picker(prompt_bufnr):move_selection(change * count)

	local selection = action_state.get_selected_entry()
	Themer.PreviewTheme(Themer.Themes[selection.index])
end




function ClosePicker (prompt_bufnr)
	local picker = action_state.get_current_picker(prompt_bufnr)
	local original_win_id = picker.original_win_id
	local cursor_valid, original_cursor = pcall(vim.api.nvim_win_get_cursor, original_win_id)

	actions.close_pum(prompt_bufnr)
	pickers.on_close_prompt(prompt_bufnr)

	pcall(vim.api.nvim_set_current_win, original_win_id)
	if cursor_valid and vim.api.nvim_get_mode().mode == "i" and picker._original_mode ~= "i" then
		pcall(vim.api.nvim_win_set_cursor, original_win_id, { original_cursor[1], original_cursor[2] + 1 })
	end

	Themer.SetThemeFromCache()
end


Themer.SaveTheme = function (theme)
    local file = io.open(vim.fn.stdpath('data') .. '/themer-cache', 'w')
    if file then
        local serialized_theme = vim.json.encode(theme)
        file:write(serialized_theme)
        file:close()
        return true
	end
	return false
end


Themer.ReadTheme = function ()
    local file = io.open(vim.fn.stdpath('data') .. '/themer-cache', 'r')
    if file then
        local serialized_theme = file:read('*a')
        file:close()
        local ok, theme = pcall(vim.json.decode, serialized_theme)
        if ok then
            return theme
		end
		return nil
	end
	return nil
end


Themer.SetTheme = function (theme, write_to_file)
    vim.cmd("colorscheme " .. theme.cmd)
	if write_to_file then
		Themer.SaveTheme(theme)
	end

	vim.o.background = theme.background
	if TransparentBackground == true then
		vim.cmd[[hi Normal guibg=NONE ctermbg=NONE]]
		vim.cmd[[hi SignColumn guibg=NONE ctermbg=NONE]]
		vim.cmd[[hi StatusLine guibg=NONE ctermbg=NONE]]
		vim.cmd[[hi StatusLineNC guibg=NONE ctermbg=NONE]]
		vim.cmd[[hi VertSplit guibg=NONE ctermbg=NONE]]
	end
end


Themer.GetCurrentThemeIndex = function ()
	local current_theme = Themer.ReadTheme()
	if current_theme == nil then
		return 1
	end
	local counter = 0
	for _, theme in ipairs(Themer.Themes) do
		counter = counter + 1
		if theme.name == current_theme.name and theme.cmd == current_theme.cmd and theme.background == current_theme.background then
			return counter
		end
	end
	return 1
end


Themer.SetThemeFromCache = function ()
    local theme = Themer.ReadTheme()
    if theme then
        Themer.SetTheme(theme, true)
    else
        Themer.SetTheme(Themer.Themes[1], true)
    end
end


Themer.PreviewTheme = function (theme)
	Themer.SetTheme(theme, false)
end


Themer.PickTheme = function ()
    local picker = pickers.new({}, {
        prompt_title = "Select Theme",
        finder = finders.new_table {
            results = Themer.Themes,
            entry_maker = function(entry)
                return {
                    display = entry.name,
                    value = entry,
                    ordinal = entry.name,
                }
            end,
        },

        attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				Themer.SelectDefault()
				actions.close(prompt_bufnr)
			end)
			action_set.shift_selection:replace(Themer.ShiftSelection)
			actions.close:replace(ClosePicker)
            return true
        end,
    })

	picker.default_selection_index = Themer.GetCurrentThemeIndex()
	picker:find()
end

return Themer

