# Helps iron out some problems
Encoding.default_external = "UTF-8"

module Omniboard; end

# Rubyfocus library
require "rubyfocus"

# FileUtils for making directories
require "fileutils"

# ERB for rendering web
require "erb"

# Require library files
require "omniboard/core_ext"
require "omniboard/project_wrapper"
require "omniboard/property"
require "omniboard/omniboard"
require "omniboard/column"
require "omniboard/colour"
require "omniboard/group"
require "omniboard/renderer"
require "omniboard/styled_text_element"
require "omniboard/styled_text"
