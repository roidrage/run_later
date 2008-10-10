require 'timeout'

module RunLater
  class Worker
    attr_accessor :thread
    cattr_accessor :logger
    
    def initialize(logger = RAILS_DEFAULT_LOGGER)
      self.logger = logger
      @thread = Thread.new {
        loop {
          process_queue
        }
      }
    end
    
    def self.instance
      @worker ||= RunLater::Worker.new
    end

    def self.cleanup
      begin
        Timeout::timeout 10 do
          loop do
            break unless instance.thread[:running]
          end
        end
      rescue Timeout::Error
        logger.warn("Worker thread takes too long and willed be killed.")
        instance.thread.kill
        @worker = RunLater::Worker.new
      end
    end
    
    def process_queue
      begin
        while block = RunLater.queue.pop
          Thread.pass
          Thread.current[:running] = true
          block.call
          Thread.current[:running] = false
        end
      rescue Exception => e
        logger.error("Worker thread crashed, retrying. Error was: #{e}")
        Thread.current[:running] = false
        retry
      end
    end
  end
end