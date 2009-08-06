$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'json'

include SpecHelper

describe TextConverter::Service do
  before do
    @converter = TextConverter.new
    @converter.stub!(:json).and_return(JSON.load(open(fixture('items.json')).read))
  end

  it 'should build url' do
    service = @converter.service('アレ')

    service.build_url('テストです').should eql('http://areare.jgate.de/convert?q=%E3%83%86%E3%82%B9%E3%83%88%E3%81%A7%E3%81%99')
  end

  it 'should parse html' do
    service = TextConverter::Service.new('foo', 'url' => 'http://example.com/', 'charset' => 'utf8', 'xpath' => '(//p)[2]')

    service.parse(<<_HTML_).should eql('かきくけこ')
<html>
<head>
<title>foo</title>
</head>
<body>
<p>あいうえお</p>
<p>かきくけこ</p>
</body>
</html>
_HTML_
  end

  it 'should parse html without DOCTYPE with xpath id() function' do
    service = TextConverter::Service.new('foo', 'url' => 'http://example.com/', 'charset' => 'utf8', 'xpath' => 'id("bar")')

    service.parse(<<_HTML_).should eql('かきくけこ')
<html>
<head>
<title>foo</title>
</head>
<body>
<p>あいうえお</p>
<p id="bar">かきくけこ</p>
</body>
</html>
_HTML_
  end
end

