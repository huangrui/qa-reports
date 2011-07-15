module ActionView
  # = Action View Cache Helper
  module Helpers
    module CacheHelper

    private
      # TODO: Create an object that has caching read/write on it
      def fragment_for(name = {}, options = nil, &block) #:nodoc:
        if controller.fragment_exist?(name, options)
          controller.read_fragment(name, options)
        else
          # VIEW TODO: Make #capture usable outside of ERB
          # This dance is needed because Builder can't use capture
          pos = output_buffer.length
          yield
          if output_buffer.html_safe?
            safe_output_buffer = output_buffer.to_str
            fragment = safe_output_buffer.slice!(pos..-1)
            self.output_buffer = ActionView::OutputBuffer.new(safe_output_buffer)
          else
            fragment = output_buffer.slice!(pos..-1)
          end
          controller.write_fragment(name, fragment, options)
        end
      end
    end
  end
end
