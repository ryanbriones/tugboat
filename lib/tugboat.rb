require 'fileutils'

module Tugboat
end

# Include the FileUtils file manipulation functions in the top level module,
# but mark them private so that they don't unintentionally define methods on
# other objects.
#
# stolen from Jim Weirich's awesome rake rubygem

include FileUtils
private(*FileUtils.instance_methods(false))
