require 'run_later/worker'
require 'run_later/instance_methods'

ActionController::Base.send(:include, RunLater::InstanceMethods)
ActiveRecord::Base.send(:include, RunLater::InstanceMethods)

RunLater::Worker.new