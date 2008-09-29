require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'run_later/worker'
require 'run_later/instance_methods'
require 'mocha'

class WorkerTest < Test::Unit::TestCase
  include RunLater::InstanceMethods
  
  context "A worker instance" do
    setup do
      @logger = stub(:logger)
      @worker = RunLater::Worker.new(@logger)
    end
    
    should "process the queue" do
      run_later do
        "awesome!"
      end
      sleep 0.1
      assert_equal 0, RunLater.queue.size
    end
    
    context "when throwing an error inside the block" do
      setup do
        run_later do
          "awesome!"
        end
      end
      
      should "continue working through the queue" do
        @logger.expects(:error)
        queue = stub(:queue)
        queue.stubs(:pop).raises(Exception).then.returns nil
        RunLater.stubs(:queue).returns(queue)
        assert_nothing_raised {@worker.process_queue}
      end
    end
  end
end