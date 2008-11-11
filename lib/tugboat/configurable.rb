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

      def configuration_options
        @configuration_options
      end

      def tugboat_configured_as=(configured_as, short_as = nil)
        @tugboat_configured_as = configured_as
        @tugboat_configured_as_short = short_as
      end

      def tugboat_configured_as(format = nil)
        case format
        when :short
          @tugboat_configured_as_short || (@tugboat_configured_as || self.to_s)[self.to_s.rindex(':')+1..-1][0,3].downcase
        else
          @tugboat_configured_as || self.to_s[self.to_s.rindex(':')+1..-1].gsub(/\B[A-Z]/) { |c| "_#{c.downcase}" }.downcase
        end
      end
    end
    
    module InstanceMethods
      def dump_configuration(parent, indentation = 0)
        output_lines = []
        
        header = %Q%#{parent}.#{(self.class.tugboat_configured_as)}("#{self.name}")%
        header << " do |#{self.class.tugboat_configured_as(:short)}|" if any_configuration_options?
        output_lines << Tugboat::Configurable.indent(header, indentation)

        if any_configuration_options?
          self.class.configuration_options.each do |option|
            if self.send(option)
              line = %Q%#{self.class.tugboat_configured_as(:short)}.#{option} = #{self.send(option).inspect}%
              output_lines << Tugboat::Configurable.indent(line, indentation + 2)
            end
          end
        end

        output_lines << Tugboat::Configurable.indent('end', indentation) if any_configuration_options?

        return output_lines.join("\n")
      end

      def any_configuration_options?
        self.class.configuration_options.any? { |opt| self.send(opt) }
      end
    end
  end
end

module Kernel
  def tugboat_configurable(klass = nil)
    klass ||= eval("self", binding)
    klass.extend(Tugboat::Configurable::ClassMethods)
    klass.send(:include, Tugboat::Configurable::InstanceMethods)
  end
end
