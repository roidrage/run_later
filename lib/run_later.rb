require 'run_later/worker'

module RunLater
  @@queue = ::Queue.new
  
  def self.queue
    @@queue
  end
  
  def run_later(&block)
    @@queue << block
  end
end

ActionController::Base.send(:include, RunLater)
ActiveRecord::Base.send(:include, RunLater)

RunLater::Worker.new