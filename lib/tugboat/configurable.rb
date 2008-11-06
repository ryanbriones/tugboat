module Tugboat
  module Configurable
    def self.indent(line, indentation = 0)
      (' ' * indentation) + line
    end
    
    module ClassMethods
      def configuration_option(*keys)
        @configuration_options ||= []
      
        keys.each do |option|
          next if @configuration_options.include?(option)
        
          @configuration_options << option
          attr_accessor option
        end
      end
    end
    
    module InstanceMethods
      def dump_configuration(parent, indentation = 0)
        output_lines = []
        
        application_header = %Q%#{parent}.application("#{self.name}")%
        application_header << " do |app|" if any_configuration_options?
        output_lines << Tugboat::Configurable.indent(application_header, indentation)

        if any_configuration_options?
          self.class.class_eval { @configuration_options }.each do |option|
            if self.send(option)
              output_lines << Tugboat::Configurable.indent(%Q%app.#{option} = #{self.send(option).inspect}%, indentation + 2)
            end
          end
        end

        output_lines << Tugboat::Configurable.indent('end', indentation) if any_configuration_options?

        return output_lines.join("\n")
      end

      def any_configuration_options?
        self.class.class_eval { @configuration_options }.any? { |opt| self.send(opt) }
      end
    end
  end
end

module Kernel
  def has_tugboat_configuration(klass)
    klass.extend(Tugboat::Configurable::ClassMethods)
    klass.send(:include, Tugboat::Configurable::InstanceMethods)
  end
end
