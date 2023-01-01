local util = require("fzw.util")
local cmd = util.cmd
local au = util.au
local rt = util.rt
local rev = util.array_reverse
local match_front = util.match_front
local fill_spaces = util.fill_spaces
local rep_n = util.replace_nth
local fuzzy = require("fzw.fuzzy")
local which = require("fzw.which")
local output_obj_gen = require("fzw.output").output_obj_gen
local static = require("fzw.static")
local bmap = static.bmap
local _g = static._g
local input_win_row_offset = static.input_win_row_offset
local sign_group_prompt = static.sign_group_prompt
local sign_group_which = static.sign_group_which
local prefix_size = static.prefix_size
local cell = require("fzw.cell")
local _update_output_obj = require("fzw.output")._update_output_obj
local fg_which = "#f2cdcd" --"#f38ba8"
local fg_fuzzy = "#89b4fa" -- "#72D4F2" -- "#7ec9d8"
local fg_rem = "#585b70"
local which_insert_map = require("fzw.which_map").setup

local function setup()
    -- vim.api.nvim_set_hl(0, "FzwWhichRem", { fg = fg_rem, bold = true })
    -- vim.api.nvim_set_hl(0, "FzwFuzzy", { fg = fg_fuzzy, bold = true })
    -- vim.api.nvim_set_hl(0, "FzwFreeze", { fg = fg_rem })
    vim.api.nvim_set_hl(0, "FzwWhichRem", { default = true, link = "Comment" })
    vim.api.nvim_set_hl(0, "FzwFuzzy", { default = true, link = "FloatBorder" })
    vim.api.nvim_set_hl(0, "FzwFreeze", { default = true, link = "Comment" })
end

local function objs_setup(fuzzy_obj, which_obj, output_obj, caller_obj, choices_obj, callback)
    local objs = { fuzzy_obj, which_obj, output_obj }

    local del = function() -- deliminator of the whole process
        for _, o in ipairs(objs) do
            if vim.api.nvim_win_is_valid(o.buf) then
                vim.api.nvim_set_current_win(o.win)
                vim.api.nvim_buf_delete(o.buf, { force = true })
            end
            if vim.api.nvim_win_is_valid(o.win) then
                vim.api.nvim_win_close(o.win, true)
            end
        end
        if vim.api.nvim_win_is_valid(caller_obj.win) then
            vim.api.nvim_set_current_win(caller_obj.win)
        end
    end
    for _, o in ipairs(objs) do
        au(_g, "BufWinLeave", function()
            del()
        end, { buffer = o.buf })
    end

    local inputs = { fuzzy_obj, which_obj }
    local to_which = function()
        vim.api.nvim_set_current_win(which_obj.win)
    end
    local to_fuzzy = function()
        vim.api.nvim_set_current_win(fuzzy_obj.win)
    end
    for _, o in ipairs(inputs) do
        bmap(o.buf, { "i", "n" }, "<c-c>", del, "quit")
        bmap(o.buf, { "n" }, "<esc>", del, "quit")
        bmap(o.buf, { "n" }, "m", "", "quit")
    end
    local toggle = "<C-T>"
    bmap(fuzzy_obj.buf, { "i", "n" }, toggle, to_which, "start which key mode")
    bmap(which_obj.buf, { "i", "n" }, toggle, to_fuzzy, "start which key mode")
    local black_dict = which_insert_map(which_obj.buf, { toggle, "<C-C>" })
    local select_ = function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local which_line = vim.api.nvim_buf_get_lines(which_obj.buf, 0, -1, true)[1]
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            if match.key == which_line then
                del()
                callback(match.id)
                return
            end
        end
    end
    bmap(which_obj.buf, { "n", "i" }, "<cr>", select_, "select matched which key")
    bmap(fuzzy_obj.buf, { "n", "i" }, "<cr>", select_, "select matched which key")
    return { del = del, black_dict = black_dict }
end

local sign_place_which = function(choices_obj, which_obj, fuzzy_obj, output_obj, obj_handlers)
    local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
    for _, match in ipairs(vim.fn.getmatches(output_obj.win)) do
        if match.group == "IncSearch" then
            vim.fn.matchdelete(match.id, output_obj.win)
        end
    end
    -- local prefix_size = 7
    local matches_obj, poss = (function()
        if fuzzy_line == "" then
            return choices_obj
        else
            local obj = vim.fn.matchfuzzypos(choices_obj, fuzzy_line, { key = "text" })
            local poss = obj[2]
            return rev(obj[1]), rev(poss)
        end
    end)()
    local which_line = vim.api.nvim_buf_get_lines(which_obj.buf, 0, -1, true)[1]
    local ids = {}
    local texts = {}
    local match_posses = {}
    local function meta_key(sub)
        if string.match(sub, "^<") == "<" then
            local till = sub:match("^<[%w%-]+>")
            if till ~= nil then
                return #till
            end
        end
        return vim.fn.strdisplaywidth(string.match(sub, "."))
    end

    for lnum, match in ipairs(matches_obj) do
        if match_front(match.key, which_line) then
            table.insert(ids, { id = match.id, key = match.key })
            local sub = string.sub(match.key, 1 + #which_line, prefix_size + #which_line)

            local str = fill_spaces(sub, prefix_size)
            local text = string.format(" %s %s %s", str, "→", match.text)
            table.insert(texts, text)

            local till_len = meta_key(sub)
            table.insert(match_posses, { lnum, till_len })
        end
    end
    local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset
    _update_output_obj(output_obj, texts, vim.o.lines, _row_offset + input_win_row_offset)
    -- for _, match in ipairs(vim.fn.getmatches(output_obj.win)) do
    --     if match.group == "FzwWhich" then
    --         vim.fn.matchdelete(match.id, output_obj.win)
    --     end
    -- end
    for i, match_pos in ipairs(match_posses) do
        -- vim.fn.matchaddpos("FzwWhichRem", { { i, 2, prefix_size } }, 9, -1, { window = output_obj.win })
        -- vim.fn.matchaddpos("FzwWhich", { { i, 2, match_pos[2] } }, 10, -1, { window = output_obj.win })
        -- vim.fn.matchaddpos(
        --     "FzwArrow",
        --     { { i, prefix_size + 3, vim.fn.strdisplaywidth("→") } },
        --     9,
        --     -1,
        --     { window = output_obj.win }
        -- )
        if poss ~= nil then
            for _, v in ipairs(poss[match_pos[1]]) do
                vim.api.nvim_buf_add_highlight(
                    output_obj.buf,
                    0,
                    "FzwFuzzy",
                    i - 1,
                    v + prefix_size + 6,
                    v + prefix_size + 7
                )
                -- vim.fn.matchaddpos("IncSearch", { { i, v + prefix_size + 7 } }, 0, -1, { window = output_obj["win"] })
            end
        end
    end

    if which_line == "" then
        return nil
    else
        if #ids == 1 and ids[1].key == which_line then
            return ids[1].id
        else
            return nil
        end
    end
end

local function swap_win_pos(up, down)
    local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
    local height = 1
    local row = vim.o.lines - height - _row_offset - 1
    local wcnf = vim.api.nvim_win_get_config(up.win)
    vim.api.nvim_win_set_config(up.win, vim.fn.extend(wcnf, { row = row - input_win_row_offset }))
    local fcnf = vim.api.nvim_win_get_config(down.win)
    vim.api.nvim_win_set_config(down.win, vim.fn.extend(fcnf, { row = row }))
end

local function fuzzy_setup(which_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    au(_g, { "TextChangedI", "TextChanged" }, function()
        sign_place_which(choices_obj, which_obj, fuzzy_obj, output_obj, obj_handlers)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinEnter", function()
        -- vim.api.nvim_set_hl(0, "FzwArrow", { fg = fg_fuzzy, bold = true })
        vim.api.nvim_set_hl(0, "FzwArrow", { link = "FloatBorder" })
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "fuzzy",
            sign_group_prompt .. "fuzzy",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:Normal")
        swap_win_pos(fuzzy_obj, which_obj)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinLeave", function()
        -- vim.api.nvim_set_hl(0, "FzwArrow", { fg = fg_rem, bold = true })
        vim.api.nvim_set_hl(0, "FzwArrow", { link = "Comment" })
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_unplace(sign_group_prompt .. "fuzzy", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:Comment")
    end, { buffer = fuzzy_obj.buf })
end

local function which_setup(which_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    au(_g, "BufEnter", function()
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = which_obj.buf })
        local _, _ = pcall(function()
            require("cmp").setup.buffer({ enabled = false })
        end)
    end, { buffer = which_obj.buf })
    au(_g, "WinLeave", function()
        -- vim.api.nvim_set_hl(0, "FzwWhich", { fg = fg_rem, bold = true })
        vim.api.nvim_set_hl(0, "FzwWhich", { link = "Normal" })

        vim.fn.sign_unplace(sign_group_prompt .. "which", { buffer = which_obj.buf })
        -- vim.fn.sign_unplace(sign_group_which, { buffer = output_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            which_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(which_obj.win, "winhl", "Normal:Comment")
    end, { buffer = which_obj.buf })
    au(_g, "TextChangedI", function()
        -- vim.fn.sign_unplace(sign_group_which, { buffer = output_obj.buf })
        local id = sign_place_which(choices_obj, which_obj, fuzzy_obj, output_obj, obj_handlers)
        if id ~= nil then
            obj_handlers.del()
            callback(id)
        end
    end, { buffer = which_obj.buf })
    au(_g, "WinEnter", function()
        -- vim.api.nvim_set_hl(0, "FzwWhich", { fg = fg_which, bold = true })
        vim.api.nvim_set_hl(0, "FzwWhich", { link = "Identifier" })

        vim.api.nvim_win_set_option(which_obj.win, "winhl", "Normal:Normal")
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "which",
            sign_group_prompt .. "which",
            which_obj.buf,
            { lnum = 1, priority = 10 }
        )
        sign_place_which(choices_obj, which_obj, fuzzy_obj, output_obj, obj_handlers)
        swap_win_pos(which_obj, fuzzy_obj)
    end, { buffer = which_obj.buf })
    bmap(which_obj.buf, { "n", "i" }, "<cr>", function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local which_line = vim.api.nvim_buf_get_lines(which_obj.buf, 0, -1, true)[1]
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            if match.key == which_line then
                obj_handlers.del()
                callback(match.id)
            end
        end
    end, "match")
    bmap(which_obj.buf, { "i" }, "<C-H>", function()
        local pos = vim.api.nvim_win_get_cursor(which_obj.win)
        local line = vim.api.nvim_buf_get_lines(which_obj.buf, pos[1] - 1, pos[1], true)[1]
        local front = string.sub(line, 1, pos[2])
        local match = string.match(front, "<[%l%u%-]+>$")
        if match == nil then
            vim.api.nvim_feedkeys(rt("<C-h>"), "n", false)
        else
            local back_line = string.sub(line, pos[2] + 1)
            local new_front = string.gsub(line, "<[%l%u%-]+>$", "")
            vim.fn.sign_unplace(sign_group_prompt .. "which", { buffer = which_obj.buf })
            vim.api.nvim_buf_set_lines(which_obj.buf, pos[1] - 1, pos[1], true, { new_front .. back_line })
            vim.api.nvim_win_set_cursor(which_obj.win, { pos[1], vim.fn.strdisplaywidth(new_front) })
            vim.fn.sign_place(
                0,
                sign_group_prompt .. "which",
                sign_group_prompt .. "which",
                which_obj.buf,
                { lnum = 1, priority = 10 }
            )
        end
    end, "<C-h>")
end

local function is_array(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

-- core
local function inputlist(choices, callback, opts)
    local _opts = { prompt = "> ", selector = "which", text_insert_in_advance = "" }
    opts = opts or _opts
    for k, v in pairs(_opts) do
        if vim.fn.has_key(opts, k) == 0 then
            opts[k] = v
        end
    end

    vim.fn.sign_define(sign_group_prompt .. "fuzzy", {
        text = opts.prompt,
        texthl = "FzwFuzzy",
    })
    vim.fn.sign_define(sign_group_prompt .. "which", {
        text = opts.prompt,
        texthl = "FzwWhich",
    })
    vim.fn.sign_define(sign_group_prompt .. "freeze", {
        text = opts.prompt,
        texthl = "FzwFreeze",
    })

    local choices_list = nil
    local choices_obj = {}
    if is_array(choices) then
        choices_list = choices
        for i, val in ipairs(choices) do
            choices_obj[i] = cell.new(i, tostring(i), val)
        end
    else -- dict
        choices_list = vim.fn.values(choices)
        for key, val in pairs(choices) do
            table.insert(choices_obj, cell.new(key, key, val))
        end
    end

    local caller_obj = (function()
        local win = vim.api.nvim_get_current_win()
        return {
            win = win,
            buf = vim.api.nvim_get_current_buf(),
            original_mode = vim.api.nvim_get_mode().mode,
            cursor = vim.api.nvim_win_get_cursor(win),
            mode = vim.api.nvim_get_mode().mode,
        }
    end)()

    -- 表示用バッファを作成
    local output_obj = output_obj_gen()

    -- -- 入力用バッファを作成
    local which_obj = which.input_obj_gen(output_obj)
    local fuzzy_obj = fuzzy.input_obj_gen(output_obj, choices_list)

    local obj_handlers = objs_setup(fuzzy_obj, which_obj, output_obj, caller_obj, choices_obj, callback)
    which_setup(which_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    fuzzy_setup(which_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)

    -- vim.cmd("startinsert")
    local keys = vim.api.nvim_get_mode().mode ~= "n" and "<ESC>A" or "A"
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
    vim.api.nvim_buf_set_lines(which_obj.buf, 0, -1, true, { opts.text_insert_in_advance })
    if opts.selector == "fuzzy" then
        vim.api.nvim_set_current_win(fuzzy_obj.win)
    elseif opts.selector == "which" then
        vim.api.nvim_set_current_win(which_obj.win)
    else
        print("selector must be fuzzy or which")
        obj_handlers.del()
    end
end

local function select(items, opts, on_choice)
    vim.validate({
        items = { items, "table", false },
        on_choice = { on_choice, "function", false },
    })
    opts = opts or {}
    local choices = {}
    local format_item = opts.format_item or tostring

    for k, item in pairs(items) do
        choices[k] = format_item(item)
    end
    local callback = function(choice)
        if type(choice) == "string" then
            on_choice(items[choice], choice)
        elseif choice < 1 or choice > #items then
            on_choice(nil, nil)
        else
            on_choice(items[choice], choice)
        end
    end
    inputlist(choices, callback, opts)
end

(function()
    setup()
    local function test()
        select(
            { "tabs", "spaces", "core", "hoge", "huga", "hoge", "cole", "ghoe", "falf", "thoe", "oewi", "ooew", "feow" }
            ,
            {
                prompt = "> ",
            },
            function(choice)
                print("You chose " .. choice)
            end
        )
    end

    local function which_key()
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        local keys = vim.api.nvim_get_keymap("n")
        local choices = {}
        local g = vim.api.nvim_create_augroup("WFWhichKey", { clear = true })
        for _, val in ipairs(keys) do
            if not string.match(val.lhs, "^<Plug>") then
                local lhs = string.gsub(val.lhs, " ", "<Space>")
                choices[lhs] = val.desc --or val.rhs
            end
        end
        select(choices, {
            prompt = "> ",
            text_insert_in_advance = "<Space>",
        }, function(_, lhs)
            if win == vim.api.nvim_get_current_win() and buf == vim.api.nvim_get_current_buf() then
                if vim.fn.mode() == "i" then
                    vim.api.nvim_feedkeys(rt("<esc>"), "n", 0)
                    vim.api.nvim_feedkeys(rt(lhs), "m", 0)
                else
                    print(vim.fn.mode())
                end
            end
        end)
    end

    -- test
    cmd("WF", which_key)
    local function hello()
        vim.cmd("echo 'hello'")
    end

    vim.api.nvim_set_keymap("n", "<space>mw", "", { callback = which_key, noremap = true, silent = true, desc = "wf" })
    vim.api.nvim_set_keymap("n", "<space><C-W>mw", "", {
        callback = hello,
        noremap = true,
        silent = true,
        desc = "[window] hello!",
    })
end)()
