require 'dispatcher' unless defined?(::Dispatcher)

# Cleanup code. Will only be used when cache_classes is disabled, so usually
# in development and testing mode. Ensures that the worker thread is properly
# disposed of before Rails' class unloading kicks in.

if defined?(ActionController::MiddlewareStack::Middleware)
  # Rack-supported version for Rails >= 2.3.x
  class RunLater::Cleanup
    def initialize(app)
      @app = app
    end
  
    def call(env)
      @app.call(env)
    ensure
      RunLater::Worker.cleanup
    end
  end

  unless Rails.configuration.cache_classes
    ActionController::Dispatcher.middleware.push(ActionController::MiddlewareStack::Middleware.new(RunLater::Cleanup))
  end
else
  # "Legacy" Rails 2.2 version
  class ActionController::Dispatcher
    def cleanup_application_with_thread_check
      RunLater::Worker.cleanup
      cleanup_application_without_thread_check
    end

    alias_method_chain :cleanup_application, :thread_check
  end
end