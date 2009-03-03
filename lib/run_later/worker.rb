require 'timeout'

module RunLater
  class Worker
    attr_accessor :thread
    cattr_accessor :logger

    def initialize(logger = RAILS_DEFAULT_LOGGER)
      self.logger = logger
      @thread = Thread.new {
        trap :INT do
          RunLater::Worker.shutdown
          exit
        end

        loop {
          process_queue
        }
      }
    end
    
    def self.instance
      @worker ||= RunLater::Worker.new
    end

    def self.flush_logger
      logger.flush if logger.respond_to?(:flush)
    end
    
    def flush_logger
      self.class.flush_logger
    end
    
    def self.shutdown
      begin
        Timeout::timeout 10 do
          loop {break unless instance.thread[:running]}
        end
      rescue Timeout::Error
        logger.error("Worker thread timed out. Forcing shutdown.")
      ensure
        instance.thread.kill!
      end
    end

    def self.cleanup
      begin
        Timeout::timeout 10 do
          loop do
            break unless instance.thread[:running]
            # When run in Passenger, explicitly pass control to another thread
            # which will in return hand over control to the worker thread.
            # However, it doesn't work in Passenger 2.1.0, since it removes
            # all its classes before handing the request over to Rails.
            Thread.pass if defined?(::Passenger) or defined?(::PhusionPassenger)
          end
        end
      rescue Timeout::Error
        logger.warn("Worker thread takes too long and will be killed.")
        flush_logger
        instance.thread.kill!
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
          flush_logger
        end
      rescue Exception => e
        logger.error("Worker thread crashed, retrying. Error was: #{e}")
        flush_logger
        Thread.current[:running] = false
        retry
      end
    end
  end
end
