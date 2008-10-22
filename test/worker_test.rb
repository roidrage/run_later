require File.dirname(__FILE__) + '/test_helper'
require 'run_later/worker'
require 'run_later/instance_methods'
require 'timeout'

class WorkerTest < Test::Unit::TestCase
  include RunLater::InstanceMethods
  
  context "A worker instance" do
    setup do
      @logger = stub(:logger)
      @logger.stubs(:error)
      @logger.stubs(:flush)
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
        
        queue = stub(:queue)
        queue.stubs(:pop).raises(Exception).then.returns nil
        RunLater.stubs(:queue).returns(queue)
      end
      
      should "continue working through the queue" do
        assert_nothing_raised {@worker.process_queue}
      end
      
      should "log an error" do
        @logger.expects(:error)
        @worker.process_queue
      end
    end

    context "when shutting down the worker" do
      should "kill the thread" do
        RunLater::Worker.instance.thread.expects(:kill!)
        RunLater::Worker.shutdown
      end
      
      should "not re-raise a timeout error" do
        RunLater::Worker.expects(:loop).yields.raises(Timeout::Error)
        assert_nothing_raised {RunLater::Worker.shutdown}
      end
    end
  end
end
