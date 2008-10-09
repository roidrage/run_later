require 'run_later/worker'
require 'run_later/instance_methods'

ActionController::Base.send(:include, RunLater::InstanceMethods)

require 'dispatcher' unless defined?(::Dispatcher)

RunLater::Worker.instance

class ActionController::Dispatcher
  def cleanup_application_with_thread_check
    loop do
      break unless RunLater::Worker.instance.thread[:running]
    end
    cleanup_application_without_thread_check
  end

  alias_method_chain :cleanup_application, :thread_check
end