module RunLater
  class Worker
    attr_accessor :logger
    
    def initialize(logger = RAILS_DEFAULT_LOGGER)
      @logger = logger
      @thread = Thread.new {
        loop { 
          process_queue
        }
      }
    end
    
    def process_queue
      begin
        while block = RunLater.queue.pop
          Thread.pass
          block.call
        end
      rescue Exception => e
        logger.error("Worker thread crashed, retrying.")
        retry
      end
    end
  end
end