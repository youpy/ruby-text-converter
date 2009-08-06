$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'json'

include SpecHelper

describe TextConverter do
  before do
    @converter = TextConverter.new
    @converter.stub!(:json).and_return(JSON.load(open(fixture('items.json')).read))
  end

  it 'should convert text using a service returning plain text' do
    service = @converter.service('アレ')
    service.stub!(:get).and_return(open(fixture('are.txt')).read)
    @converter.stub!(:service).and_return(service)

    @converter.convert('アレ', 'テストです').should eql('アレです')
  end

  it 'should convert text using a service returning html' do
    service = @converter.service('アルベド語')
    service.stub!(:get).and_return(open(fixture('arubedo.html')).read)
    @converter.stub!(:service).and_return(service)

    @converter.convert('アルベド語', 'テストです').should eql('テストベヌ')
  end

  it 'should raise error if no service are found by name' do
    lambda {
      @converter.convert('FooBar', 'テストです')
    }.should raise_error(TextConverter::NoSuchService)
  end
end

