module RunLater
  class Worker

    def initialize
      @logger = RAILS_DEFAULT_LOGGER
      @thread = Thread.new {
        loop { 
          process_queue
        }
      }
    end
    
    def process_queue
      while block = RunLater.queue.pop
        Thread.pass
        block.call
      end
    end
  end
end