-- TODO: issue with session form the previous day that counts as a start of a new session the next day
-- TODO: same issue with incorrect session time when end of previous session (might be hours ago) counts as the start of the new session
-- TODO: should log sessions with empty duration?
-- TODO: different time in current and show
-- TODO: print timeline grouped by cwd

local logger = require "logger"
logger.set_log_level(logger.INFO)

local M = {}
local heartbeat_timer = nil
local heartbeat_ms = 5000
local last_interaction_s = os.time()
local active_session_start_s = nil
local is_session_active = false
local sessions_folder = vim.fn.stdpath "config" .. "/sessions/"
local one_hour_s = 60 * 60
local one_day_s = one_hour_s * 24

local visual = {
  -- spacer = "`",
  -- timeline_active_mark = "•",
  -- timeline_passive_mark = " ",
  spacer = "",
  timeline_active_mark = "█",
  timeline_passive_mark = "░",
}

local function pretty_time_s(seconds)
  local hrs = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

local function pretty_time(ts_s)
  return os.date("%Y-%m-%dT%H:%M:%S", ts_s)
end

local function pretty_date(time_s)
  time_s = time_s or os.time()
  return os.date("%Y-%m-%d", time_s)
end

local function day_name(ts)
  return os.date("%A", ts)
end

local function start_active_session()
  if is_session_active then
    logger.debug "Active session has already started"
  else
    is_session_active = true
    active_session_start_s = os.time()
    last_interaction_s = active_session_start_s

    logger.debug("Active session has started at " .. pretty_time(active_session_start_s))
  end
end

local function get_current_sessions_info()
  local overall_duration_s, sessions_number = load_todays_sessions()

  if overall_duration_s then
    if is_session_active and active_session_start_s then
      overall_duration_s = overall_duration_s + os.time() - active_session_start_s
    end

    return overall_duration_s, sessions_number
  end

  return nil
end

local function stop_active_session()
  local last_session_duration_s = last_interaction_s - active_session_start_s
  is_session_active = false

  if last_session_duration_s > 0 then
    local latest_active_session = {
      from = pretty_time(active_session_start_s),
      to = pretty_time(last_interaction_s),
      duration_s = last_session_duration_s,
      word_dir = get_cwd(),
    }

    flush_session(latest_active_session)
    local overall_duration_s, sessions_number = get_current_sessions_info()
    -- TODO: should reset last interaction s?

    if overall_duration_s then
      logger.debug(
        "Session has stopped at "
          .. pretty_time(last_interaction_s)
          .. ". Active time "
          .. pretty_time_s(overall_duration_s)
          .. ". Last session duration "
          .. pretty_time_s(last_session_duration_s)
          .. ". Sessions today "
          .. sessions_number
      )
    end
  else
    logger.debug "Session has been skipped"
  end
end

local function heartbeat()
  local now_s = os.time()
  local time_since_last_interaction_s = now_s - last_interaction_s
  --  print("heartbeat", now_s)

  if is_session_active == true then
    if time_since_last_interaction_s * 1000 > heartbeat_ms then
      stop_active_session()
    end
  end
end

M.start = function()
  if heartbeat_timer then
    logger.debug "Heartbeat has already started"
  else
    heartbeat_timer = vim.loop.new_timer()
    if heartbeat_timer then
      heartbeat_timer:start(0, heartbeat_ms, vim.schedule_wrap(heartbeat))
      logger.info("Heartbeat has been started." .. " Inverval is " .. heartbeat_ms .. " ms")
      start_active_session()
    else
      logger.error "Failed to start cooldown timer"
    end
  end
end

M.stop = function()
  if heartbeat_timer then
    stop_active_session()
    vim.loop.timer_stop(heartbeat_timer)
    logger.debug "Heartbeat has been stopped"
    heartbeat_timer = nil
  else
    logger.info "Heartbeat has already stopped"
  end
end

vim.on_key(function(key)
  last_interaction_s = os.time()
  if is_session_active == false and heartbeat_timer ~= nil then
    start_active_session()
  end
end, vim.api.nvim_create_namespace "my-key-logger")

M.current = function()
  local overall_duration_s, sessions_number = get_current_sessions_info()

  if overall_duration_s then
    logger.info("Today's session time " .. pretty_time_s(overall_duration_s) .. ", sessions " .. sessions_number)
  else
    logger.info "No current session"
  end
end

function M.run(opts)
  local arg = opts.args

  if arg == "start" then
    M.start()
  elseif arg == "stop" then
    M.stop()
  elseif arg == "current" then
    M.current()
  elseif arg == "show" then
    M.show_timeline()
  elseif arg == "sessions" then
    M.sessions_statistics(10, true)
    M.sessions_statistics(30, false)
    M.sessions_statistics("all", false)
  else
    logger.error("Session tracker: unknown command '" .. arg .. "'")
  end
end

function get_session_storage_file_path(date)
  date = date or pretty_date()
  return sessions_folder .. date .. ".json"
end

function does_session_exist(date)
  local sessions_storage_path = get_session_storage_file_path(date)

  if vim.loop.fs_stat(sessions_storage_path) then
    if vim.fn.filereadable(sessions_storage_path) ~= 1 then
      return false
    end
  else
    return false
  end

  return true
end

function read_sessions(date)
  data = date or pretty_date()
  local sessions_storage_path = get_session_storage_file_path(date)

  if vim.loop.fs_stat(sessions_storage_path) then
    local lines = ""

    if vim.fn.filereadable(sessions_storage_path) == 1 then
      local contents = vim.fn.readfile(sessions_storage_path)

      for _, line in ipairs(contents) do
        lines = lines .. line
      end

      return vim.json.decode(lines)
    else
      logger.error "File is not readable"
    end
  else
    logger.error("Failed to read file " .. sessions_storage_path)
  end

  return nil
end

function process_sessions(sessions)
  local overall_duration_s = 0
  local sessions_number = 0

  for _, session in ipairs(sessions) do
    overall_duration_s = overall_duration_s + session.duration_s
    sessions_number = sessions_number + 1
  end

  return overall_duration_s, sessions_number
end

function load_todays_sessions()
  local sessions_storage = read_sessions()

  if sessions_storage then
    return process_sessions(sessions_storage.sessions)
  else
    return 0, 0
  end
end

function flush_session(session)
  local sessions_storage = read_sessions()

  if sessions_storage then
    session.id = #sessions_storage.sessions
    table.insert(sessions_storage.sessions, session)
  else
    sessions_storage = {
      date = pretty_date(),
      overall_duration = "",
      overall_duration_s = 0,
      sessions_number = 0,
      sessions = { session },
    }
  end

  local overall_duration_s, sessions_number = process_sessions(sessions_storage.sessions)

  sessions_storage.overall_duration = pretty_time_s(overall_duration_s)
  sessions_storage.overall_duration_s = overall_duration_s
  sessions_storage.sessions_number = sessions_number

  local sessions_storage_path = get_session_storage_file_path()
  local json = vim.json.encode(sessions_storage)
  local prettify_cmd = "jq . "
    .. sessions_storage_path
    .. " > temp.json && cat ./temp.json > "
    .. sessions_storage_path
    .. " && rm temp.json"

  vim.fn.writefile({ json }, sessions_storage_path)
  vim.fn.system(prettify_cmd)

  logger.debug("Sessions have been flushed to " .. sessions_storage_path)
  return sessions_number
end

function M.setup()
  vim.api.nvim_create_user_command("ST", function(opts)
    M.run(opts)
  end, {
    nargs = 1,
    complete = function(_, _, _)
      return { "start", "stop", "current", "show", "sessions" }
    end,
  })

  return M
end

function get_start_of_the_day_s()
  local now = os.date "*t"
  local current_day_start_s = os.time { year = now.year, month = now.month, day = now.day, hour = 0, min = 0, sec = 0 }
  return current_day_start_s
end

function parse_date_to_s(date)
  local y, m, d = date:match "^(%d+)%-(%d+)%-(%d+)"

  return os.time {
    year = tonumber(y),
    month = tonumber(m),
    day = tonumber(d),
    hour = 0,
    min = 0,
    sec = 0,
    -- TODO: how to handle that?
    -- isdst = false,
  }
end

function parse_session_ts(session)
  local function parse_iso_timestamp(ts)
    local year, month, day, hour, min, sec = ts:match "^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"

    return os.time {
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = tonumber(hour),
      min = tonumber(min),
      sec = tonumber(sec),
    }
  end

  return parse_iso_timestamp(session.from), parse_iso_timestamp(session.to)
end

function get_sessions_list()
  local sessions = {}

  for file in io.popen("ls " .. sessions_folder):lines() do
    table.insert(sessions, string.sub(file, 1, -6))
  end

  return sessions
end

function get_cwd()
  return vim.uv.cwd()
end

function M.show_timeline(date)
  date = date or pretty_date()
  local sessions_storage = read_sessions(date)

  if sessions_storage == nil then
    return false
  end

  local start_of_the_day_s = parse_date_to_s(date)
  local overall_duration_s, sessions_number = process_sessions(sessions_storage.sessions)
  local step_s = 4 * 60 -- 5 minutes
  local steps_in_hour = math.floor(60 * 60 / step_s)
  local timeline_by_hour = {}

  for i = 0, 24 do
    timeline_by_hour[i] = {}
    for j = 0, steps_in_hour - 1 do
      table.insert(timeline_by_hour[i], visual.timeline_passive_mark)
    end
  end

  local all_sessions_duration = 0

  for _, session in ipairs(sessions_storage.sessions) do
    local from_s, to_s = parse_session_ts(session)

    while from_s < to_s do
      local since_midnight_s = from_s - start_of_the_day_s

      local since_midnight_h = math.floor(since_midnight_s / 60 / 60) + 1
      local step_within_hour = math.floor((from_s % (60 * 60)) / step_s)

      timeline_by_hour[since_midnight_h][step_within_hour + 1] = visual.timeline_active_mark
      from_s = from_s + step_s
    end
  end

  local steps_in_hour = one_hour_s / step_s
  local timeline = ""
  local timeline_label = ""

  for id, line in ipairs(timeline_by_hour) do
    local hour_timeline = table.concat(timeline_by_hour[id])

    if string.find(hour_timeline, visual.timeline_active_mark) or (id >= 9 and id <= 19) then
      timeline = timeline .. hour_timeline .. visual.spacer
      local label = (id - 1) .. ":00"
      timeline_label = timeline_label .. label .. string.rep(" ", steps_in_hour - #label + #visual.spacer)
    end
  end

  print(
    pretty_date(start_of_the_day_s)
      .. "> "
      .. day_name(start_of_the_day_s)
      .. " "
      .. pretty_time_s(overall_duration_s)
      .. " of active time in "
      .. sessions_number
      .. " sessions"
  )

  print(timeline)
  print(timeline_label)
  return true
end

M.sessions_statistics = function(number_of_sessions, show_timeline)
  local sessions = get_sessions_list()

  if type(number_of_sessions) == "string" then
    number_of_sessions = #sessions
  end

  local id = math.max(#sessions - number_of_sessions, 1)
  local all_sessions_duration_s = 0

  while id <= #sessions do
    local date = sessions[id]
    id = id + 1
    local sessions = read_sessions(date)

    if sessions then
      all_sessions_duration_s = all_sessions_duration_s + sessions.overall_duration_s

      if show_timeline == true then
        M.show_timeline(date)
        print "\n"
      end
    end
  end

  local average_daily_session_s = all_sessions_duration_s / number_of_sessions
  print(
    "Average daily active time over the last "
      .. number_of_sessions
      .. " days is "
      .. pretty_time_s(average_daily_session_s)
  )
end

return M
