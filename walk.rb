# Walk through file tree

require 'find'
require 'logger'

SOURCE_TREE = File.expand_path('../../rails/', __FILE__)

def stopwatch()
  start_time = Time.now
  yield
  Time.now - start_time
end

queue = Queue.new

# Using logger for thread safety

log = Logger.new('log.txt')
log.formatter = proc do |severity, datetime, progname, message|
  "#{message}\n"
end

# Setting up readers array

WORKERS_NUM = 10

workers = WORKERS_NUM.times.map do |i|
  Thread.new do
    log.info "Starting thread [#{i}]"
    loop do
      file_name = queue.pop
      if file_name.nil?
        log.info "Terminating thread [#{i}]"
        break
      end
      next if File.directory? file_name
      log.info "Thread [#{i}] -> Reading #{file_name}"
      File.open(file_name, 'r') do |f|
        length = f.read.length
        log.info "Thread [#{i}] -> #{length} bytes was read"
      end
    end
  end
end

elapsed = stopwatch do
  # Walking the source tree
  Find.find(SOURCE_TREE) do |file_name|
    next if File.basename(file_name)[0] == '_'
    queue << file_name
  end

  # Terminating working threads
  workers_num.times { queue << nil }
  workers.each { |worker| worker.join }
end

puts "Threads: #{workers_num} Elapsed: #{elapsed} seconds"
