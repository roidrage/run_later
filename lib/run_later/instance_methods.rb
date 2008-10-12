module RunLater
  @@queue = ::Queue.new

  def self.queue
    @@queue
  end

  module InstanceMethods
    def run_later(&block)
      @@__run_later ||= RunLater::Worker.instance
      RunLater.queue << block
    end
  end
end

