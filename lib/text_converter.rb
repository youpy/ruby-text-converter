require 'json'
require 'open-uri'
require 'nokogiri'
require 'nkf'
require 'cgi'

class TextConverter
  DATABASE_URL = 'http://wedata.net/databases/Text%20Conversion%20Services/items.json'

  class Error < StandardError; end
  class NoSuchService < Error; end

  def json
    @json ||= JSON.load(open(DATABASE_URL).read)
  end

  def service(name)
    @services ||= json.inject({}) do |services, entry|
      services[entry['name']] = Service.new(entry['name'], entry['data'])
      services
    end

    service = @services[name]

    raise NoSuchService.new(name) unless service

    service
  end

  def convert(name, text)
    service(name).convert(text)
  end

  class Service
    attr_reader :name, :url, :charset, :xpath

    def initialize(name, options)
      @name = name
      @url = options['url']
      @charset = options['charset']
      @xpath = options['xpath']
    end

    def convert(text)
      parse(get(text))
    end

    def build_url(text)
      case charset
      when 'sjis'
        text = NKF.nkf('-Ws', text)
      when 'euc'
        text = NKF.nkf('-We', text)
      end

      url.gsub(/%s/, CGI.escape(text))
    end

    def get(text)
      result = open(build_url(text)).read

      case charset
      when 'sjis'
        result = NKF.nkf('-Sw', result)
      when 'euc'
        result = NKF.nkf('-Ew', result)
      end

      result
    end

    def parse(result)
      if xpath
        doctype = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
        html = Nokogiri::HTML.parse(doctype + result, nil, 'utf-8')
        result = html.xpath(xpath).text
      end

      result
    end
  end
end
