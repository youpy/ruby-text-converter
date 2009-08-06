$:.unshift File.dirname(__FILE__) + '/../lib/'

require "text_converter"
require "pathname"

module SpecHelper
  def fixture(filename)
    Pathname.new(File.dirname(__FILE__) + '/fixtures/' + filename).realpath
  end
end
