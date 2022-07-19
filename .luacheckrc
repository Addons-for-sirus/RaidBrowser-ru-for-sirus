std = "lua51c"
codes = true
ranges = true
quiet = 1

cache = true

max_line_length = false
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false

exclude_files = {
	"./.git",
	"./.github",
	"./.lua",
	"./.luarocks",
	"**/Libraries",
	".luacheckrc"
}

ignore = {
	"112", -- Mutating an undefined global variable
	"142", -- Setting an undefined field of a global variable
	"143", -- Accessing an undefined field of a global variable
	"212", -- Unused argument

	"1/SLASH_.*",			-- Setting/Mutating/Accessing an undefined global variable (Slash commands)
	"111/[A-Z][A-Z0-9_]+",	-- Setting an undefined global variable
	"113/[A-Z][A-Z0-9_]+",	-- Accessing an undefined global variable (GlobalStrings and Constants 2char+)
	"131/[A-Z][A-Z0-9_]+",	-- Unused implicitly defined global variable (GlobalStrings and Constants 2char+)
	"211/[E|L|V|P|G]",		-- Unused local variable
	"213/i",				-- Unused loop variable
	"432/self",				-- Shadowing an upvalue


}

globals = {}