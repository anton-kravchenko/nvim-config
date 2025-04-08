local function read_file_lines(path)
  local file = io.open(path, "r")

  if not file then
    print("File " .. path .. " was not found")
    return nil
  else
    local lines = {}
    for line in file:lines() do
      local index = #lines + 1
      lines[index] = line
    end

    file:close()
    return lines
  end
end

local function process_hints(raw_hint_lines)
  local hint_lines = {}
  local category = nil

  for _, hint in pairs(raw_hint_lines) do
    local skip_line = false

    if hint == "" then
      category = nil
    else
      if category == nil then
        category = hint
        skip_line = true
      end

      if skip_line == false then
        local id = #hint_lines + 1

        hint_lines[id] = {
          category = category,
          hint = hint,
        }
      end
    end
  end

  return hint_lines
end

local function select_hints(hints, number_of_hints)
  if number_of_hints > #hints then
    number_of_hints = #hints
  end

  local hints_shown = 0
  local selected_hints = {}
  local selected_hint_ids = {}

  while number_of_hints > 0 do
    local hint_id = math.random(#hints)

    if selected_hint_ids[hint_id] == nil then
      hints_shown = hints_shown + 1
      number_of_hints = number_of_hints - 1
      selected_hints[#selected_hints + 1] = hints[hint_id]

      selected_hint_ids[hint_id] = true
    else
      print("Already selected", hint_id)
    end
  end

  return selected_hints
end

local function format_hints(hints)
  local by_category = {}

  for _, v in pairs(hints) do
    local category = v.category
    local hint = v.hint

    if by_category[category] == nil then
      by_category[category] = {}
    end

    local same_category_hints = by_category[category]
    same_category_hints[#same_category_hints + 1] = hint
  end

  local hint_lines = {}
  local i = 0
  for category, hints_group in pairs(by_category) do
    hint_lines[#hint_lines + 1] = category

    for _, hint in pairs(hints_group) do
      i = i + 1

      hint_lines[#hint_lines + 1] = "    " .. hint
    end

    hint_lines[#hint_lines + 1] = ""
  end

  return hint_lines
end

local function show_popup_with_hints(hint_lines)
  local Popup = require "nui.popup"
  local event = require("nui.utils.autocmd").event

  local popup = Popup {
    enter = true,
    focusable = true,
    border = { style = "rounded", text = { top = "Cheatcodes of today" } },
    position = "50%",
    size = { width = "30%", height = "60%" },
  }

  popup:mount()

  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, hint_lines)
end

local M = {}
M.show_hints_of_the_day = function()
  local cheat_sheet_fpath = os.getenv "HOME" .. "/.config/chad.nvim/neovim_cheatsheet"
  print(cheat_sheet_fpath)

  local cheat_sheet_raw_lines = read_file_lines(cheat_sheet_fpath)
  local hints_list = process_hints(cheat_sheet_raw_lines)
  local selected_hints = select_hints(hints_list, 10)

  local hints = format_hints(selected_hints)
  show_popup_with_hints(hints)
end

return M
