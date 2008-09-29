require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'run_later/instance_methods'

class RunLaterTest < Test::Unit::TestCase
  include RunLater::InstanceMethods
  context "The queue" do

    should "be empty" do
      assert_equal 0, RunLater.queue.size
    end
    
    context "when adding a block with run_later" do
      should "queue the specified block" do
        run_later do
          "this will run later!"
        end
      
        assert_equal 1, RunLater.queue.size
      end
    end
  end
end
