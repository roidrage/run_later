require 'run_later/worker'
require 'run_later/instance_methods'
require 'run_later/cleanup'

ActionController::Base.send(:include, RunLater::InstanceMethods)
# Make run_later available both as instance and class methods
ActiveRecord::Base.send(:include, RunLater::InstanceMethods)
ActiveRecord::Base.extend(RunLater::InstanceMethods)
ActiveRecord::Observer.send(:include, RunLater::InstanceMethods)
ActiveRecord::Observer.extend(RunLater::InstanceMethods)