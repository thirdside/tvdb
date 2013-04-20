# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 6.hours do
  rake "tvdb:update"
end

every 24.hours do
  rake "tvdb:crawl"
end


# Learn more: http://github.com/javan/whenever
