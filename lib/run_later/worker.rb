module RunLater
  class Worker
    attr_accessor :logger, :thread
    
    def initialize(logger = RAILS_DEFAULT_LOGGER)
      @logger = logger
      @thread = Thread.new {
        loop {
          process_queue
        }
      }
    end
    
    def self.instance
      @worker ||= RunLater::Worker.new
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