require 'run_later/worker'
require 'run_later/instance_methods'

ActionController::Base.send(:include, RunLater::InstanceMethods)
# Make run_later available both as instance and class methods
ActiveRecord::Base.send(:include, RunLater::InstanceMethods)
ActiveRecord::Base.extend(RunLater::InstanceMethods)

require 'dispatcher' unless defined?(::Dispatcher)

class ActionController::Dispatcher
  def cleanup_application_with_thread_check
    RunLater::Worker.cleanup
    cleanup_application_without_thread_check
  end

  alias_method_chain :cleanup_application, :thread_check
end