local M = {}

local ns_id = vim.api.nvim_create_namespace("rax_c_type_prefix")
-- Global cache to store types found across all opened buffers
local global_types = {}

local type_query_str = [[
  (type_definition declarator: (type_identifier) @type)
  (struct_specifier name: (type_identifier) @type)
  (enum_specifier name: (type_identifier) @type)
]]

local func_query_str = [[
  (function_declarator declarator: (identifier) @func_name)
  (call_expression function: (identifier) @func_name)
]]

-- Scans the current buffer and adds types to the global registry
local function index_types()
    local bufnr = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "c")
    if not ok or not parser then return end

    local tree = parser:parse()[1]
    local type_query = vim.treesitter.query.parse("c", type_query_str)
    
    for _, node in type_query:iter_captures(tree:root(), bufnr, 0, -1) do
        local type_name = vim.treesitter.get_node_text(node, bufnr)
        if type_name then
            global_types[type_name] = true
        end
    end
end

function M.clear_highlights()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    end
end

function M.refresh_highlights()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= "c" and vim.bo[bufnr].filetype ~= "cpp" then return end

    -- 1. Update the index with types from the current file
    index_types()

    -- 2. Sort current global types by length (Longest Match)
    local sorted_types = {}
    for t in pairs(global_types) do table.insert(sorted_types, t) end
    table.sort(sorted_types, function(a, b) return #a > #b end)

    -- 3. Apply highlights
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "c")
    if not ok or not parser then return end
    
    local tree = parser:parse()[1]
    local func_query = vim.treesitter.query.parse("c", func_query_str)
    
    M.clear_highlights()

    for _, node in func_query:iter_captures(tree:root(), bufnr, 0, -1) do
        local func_full_name = vim.treesitter.get_node_text(node, bufnr)
        local start_row, start_col, _, _ = node:range()

        for _, type_name in ipairs(sorted_types) do
            local prefix = type_name .. "_"
            if func_full_name:sub(1, #prefix) == prefix then
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_row, start_col, {
                    end_row = start_row,
                    end_col = start_col + #type_name,
                    hl_group = "@type", 
                    priority = 200,
                })
                break 
            end
        end
    end
end

function M.setup()
    vim.api.nvim_create_user_command("CTypePrefixRefresh", M.refresh_highlights, {})
    vim.api.nvim_create_user_command("CTypePrefixClear", M.clear_highlights, {})
    -- Command to wipe the global cache if you rename a type
    vim.api.nvim_create_user_command("CTypePrefixResetCache", function() 
        global_types = {}
        M.refresh_highlights()
    end, {})

    local group = vim.api.nvim_create_augroup("RaxTypePrefix", { clear = true })
    
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
        group = group,
        pattern = { "*.c", "*.h" },
        callback = function()
            vim.schedule(M.refresh_highlights)
        end,
    })
end

return M
