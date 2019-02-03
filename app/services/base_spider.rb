class BaseSpider
  REQUEST_INTERVAL = 1
  MAX_URLS = 1000
  DATE_REG = /(\d{4}) (\d{2}) (\d{2}) (\d{4})|(\d{2})\/(\d{2})\/(\d{2})/
  LINK_REG = /(\d+)\/(\d+)\/(all)|(events\/)(\d+)-(\d+)|(\?page=\d+)/
  IMG_REG = /\A((?!(facebook|twitter|flickr|youtube|instagram|logo)).)*\z/

  attr_accessor :processor, :urls, :handlers, :results, :interval, :errors, :max_urls

  def initialize(processor, options = {})
    @processor = processor

    @results      = []
    @errors       = []
    @urls         = []
    @handlers     = {}
    @robotstxt    = nil
    
    @interval = options.fetch(:interval, REQUEST_INTERVAL)
    @max_urls = options.fetch(:max_urls, MAX_URLS)

    if valid?(@processor[:root])
      fetch_disallowed_paths(@processor[:root])
      # Check if URL is valid and allowed to scrape
      enqueue(@processor[:root], @processor[:handler]) unless disallowed?(@processor[:root])
    end
  end

  def fetch_disallowed_paths(url)
    uri = URI.parse(url)
    response = Faraday.get "#{uri.scheme}://#{uri.host}/robots.txt"
    @robotstxt = response.body.scan(/Disallow:\ (.*)/ix)
  end
  
  def disallowed?(url)
    uri = URI.parse(url)
    @robotstxt.include? uri.path
  end
  
  def valid?(url)
    Faraday.get(url).status == 200
  end

  def enqueue(url, method, data = {})
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: data }
  end

  def record(data = {})
    @results << data
  end
  
  def crawl
    index = 0
    while index < @urls.count && index <= @max_urls - 1 
      url = @urls[index]
      handler = @handlers[url]
      next unless url
      begin
        log "Handling", url.inspect
        send(handler[:method], agent.get(url), handler[:data])
      rescue => ex
        log "Error", "#{url.inspect}, #{ex}"
        add_error(url: url, handler: handler, error: ex.message)
      end
      sleep @interval if @interval > 0
      index += 1
    end
  end

  def log(label, info)
    warn "#{label} : #{info}"
  end

  def add_error(attrs)
    @errors << attrs
  end

  def agent
    @agent ||= Mechanize.new
  end
end
