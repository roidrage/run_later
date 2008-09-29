module RunLater
  @@queue = ::Queue.new

  def self.queue
    @@queue
  end

  module InstanceMethods
    def run_later(&block)
      RunLater.queue << block
    end
  end
end

