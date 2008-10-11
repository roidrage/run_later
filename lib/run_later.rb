require 'run_later/worker'
require 'run_later/instance_methods'

ActionController::Base.send(:include, RunLater::InstanceMethods)

require 'dispatcher' unless defined?(::Dispatcher)

class ActionController::Dispatcher
  before_dispatch :check_worker_thread
  
  def check_worker_thread
    @__runlater ||= RunLater::Worker.instance
  end
  
  def cleanup_application_with_thread_check
    RunLater::Worker.cleanup
    cleanup_application_without_thread_check
  end

  alias_method_chain :cleanup_application, :thread_check
end