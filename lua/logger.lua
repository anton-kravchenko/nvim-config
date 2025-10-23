local M = {}

local DEBUG = vim.log.levels.DEBUG
local INFO = vim.log.levels.INFO
local ERROR = vim.log.levels.ERROR

local log_level = vim.log.levels.INFO

local function log(level, message)
  if level >= log_level then
    vim.notify(message, level)
  end
end

M.set_log_level = function(level)
  if level == DEBUG or level == INFO or level == ERROR then
    log_level = level
  else
    print "Log level is not supported."
    print(level, DEBUG, INFO, ERROR)
  end
end

M.debug = function(message)
  log(vim.log.levels.DEBUG, message)
end

M.info = function(message)
  log(vim.log.levels.INFO, message)
end

M.error = function(message)
  log(vim.log.levels.ERROR, message)
end

M.DEBUG = DEBUG
M.INFO = INFO
M.ERROR = ERROR

return M
