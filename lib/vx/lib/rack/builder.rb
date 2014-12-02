require File.expand_path("../builder/version", __FILE__)

module Vx
  module Lib
    module Rack

      class Builder
        def initialize(default_app = nil,&block)
          @use, @map, @run = [], nil, default_app
          instance_eval(&block) if block_given?
        end

        def self.app(default_app = nil, &block)
          self.new(default_app, &block).to_app
        end

        # Specifies middleware to use in a stack.
        #
        #   class Middleware
        #     def initialize(app)
        #       @app = app
        #     end
        #
        #     def call(env)
        #       env["rack.some_header"] = "setting an example"
        #       @app.call(env)
        #     end
        #   end
        #
        #   use Middleware
        #   run lambda { |env| [200, { "Content-Type => "text/plain" }, ["OK"]] }
        #
        # All requests through to this application will first be processed by the middleware class.
        # The +call+ method in this example sets an additional environment key which then can be
        # referenced in the application if required.
        def use(middleware, *args, &block)
          if @map
            mapping, @map = @map, nil
            @use << proc { |app| generate_map app, mapping }
          end
          @use << proc { |app| middleware.new(app, *args, &block) }
        end

        def to_app(app)
          app ||= @run
          fail "missing run or map statement" unless app
          @use.reverse.inject(app) { |a,e| e[a] }
        end

        def call(env)
          to_app.call(env)
        end
      end

    end
  end
end
