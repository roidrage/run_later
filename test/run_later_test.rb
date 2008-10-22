require File.dirname(__FILE__) + '/test_helper'
require 'run_later/instance_methods'
require 'run_later/worker'

class RunLaterTest < Test::Unit::TestCase
  include RunLater::InstanceMethods
  context "The queue" do

    should "be empty" do
      assert_equal 0, RunLater.queue.size
    end
    
    context "when adding a block with run_later" do
      setup do
        RunLater::Worker.instance.thread.kill!
      end
      
      should "queue the specified block" do
        run_later do
          "this will run later!"
        end
      
        assert_equal 1, RunLater.queue.size
      end
      
      context "with run_now set" do
        setup do
          RunLater.run_now = true
        end

        teardown do
          RunLater.run_now = false
        end

        should "call the block immediately" do
          ran_block = false
          blk = proc {ran_block = true}
          run_later &blk
          assert ran_block
        end

        should "not fetch the worker instance" do
          RunLater::Worker.expects(:instance).never
          run_later { 'sup!'}
        end
      end
    end
  end
end
