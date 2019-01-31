class Spider
  REQUEST_INTERVAL = 1
  MAX_URLS = 1000
  DATE_REG = /(Mon?|Tue?|Wed?|Thu?|Fri?|Sat?|Sun?) (\d+) (Jan?|Feb?|Mar?|Apr?|May|Jun?|Jul?|Aug?|Sep?|Oct?|Nov?|Dec?) (\d+)|(\d+) (\d+) (\d+) (to) (\d+) (\d+) (\d+)/
  LINK_REG = /(\d+)\/(\d+)\/(all)|(events\/)(\d+)-(\d+)|(\?page=\d+)/

  attr_reader :processor, :urls, :handlers, :results, :interval, :errors, :max_urls

  def initialize(processor, options = {})
    @processor = processor

    @results   = []
    @urls      = []
    @errors    = []
    @handlers  = {}

    @interval = options.fetch(:interval, REQUEST_INTERVAL)
    @max_urls = options.fetch(:max_urls, MAX_URLS)
    enqueue(@processor[:root], @processor[:handler])
  end

  def enqueue(url, method, data = [])
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: data }
  end

  def record(data = [])
    @results << data.flatten
  end

  def process_index(page, data = [])
    page.links_with(href: LINK_REG).each do |link|
      enqueue(link.href, :process_index)
    end

    fetch_events(page, data = [])
  end

  def fetch_events(page, data = [])
    divs = page.search('div').group_by { |tag| tag['class'] }.reject { |k,v| k.nil? || v.nil? }
    divs.each do |classname, elements|
      next if elements.count < 5
      result = elements.flat_map do |div|
        text = clean(div.inner_text)
        date = clean(text.scan(DATE_REG).join(' '))
        next if text.empty? && date.empty?
        {
          websource: page.uri.hostname,
          body: text,
          date: format_date(date) 
        }
      end
      record(result.flatten)
    end
  end

  def format_date(date)
    DateTime.parse date rescue nil
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
        add_error(url: url, handler: handler, error: ex)
      end
      sleep @interval if @interval > 0
      index += 1
    end
  end

  def results
    @results = @results.flatten
    @results = @results.inject({}) do |r, h|
      (r[h[:date]] ||= {}).merge!(h) do |key, old, new|
        old || new
      end
      r
    end.values
  end

  def log(label, info)
    warn "#{label} : #{info}"
  end

  def clean(str)
    return nil unless str
    str.gsub(/\W|_/, ' ').squeeze(' ')
  end
  
  def add_error(attrs)
    @errors << attrs
  end

  def agent
    @agent ||= Mechanize.new
  end
end
