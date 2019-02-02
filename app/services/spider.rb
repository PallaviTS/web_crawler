class Spider
  REQUEST_INTERVAL = 1
  MAX_URLS = 1000
  DATE_REG = /(\d{4}) (\d{2}) (\d{2}) (\d{4})|(\d{2})\/(\d{2})\/(\d{2})/
  LINK_REG = /(\d+)\/(\d+)\/(all)|(events\/)(\d+)-(\d+)|(\?page=\d+)/
  IMG_REG = /\A((?!(facebook|twitter|flickr|youtube|instagram|logo)).)*\z/

  attr_accessor :processor, :urls, :handlers, :results, :interval, :errors, :max_urls

  def initialize(processor, options = {})
    @processor = processor

    @results  = []
    @urls     = []
    @handlers = {}

    @interval = options.fetch(:interval, REQUEST_INTERVAL)
    @max_urls = options.fetch(:max_urls, MAX_URLS)
    enqueue(@processor[:root], @processor[:handler])
  end

  def enqueue(url, method, data = {})
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: data }
  end

  def record(data = {})
    @results << data
  end

  def process_index(page, data = {})
    page.links_with(href: LINK_REG).each do |link|
      enqueue(link.href, :process_index)
    end
    page.images_with(src: IMG_REG).each do |img|
      root = page.xpath("//img[@src='#{img.src}']").first
      while root.node_name != 'a'
        root = root.parent
      end
      enqueue(root.attributes['href'].value, :process_articles, { image: img }) if root.attributes['href'].value
    end
  end

  def process_articles(page, data = {})
    # Find the article title
    h1 = page.search('h1').first
    # Find the common parent for <h1> and all <p>s.
    root = h1
    return unless root
    while root.node_name != 'body' and root.search('p').count < 3
      root = root.parent
    end
    body = root.search('h1', 'ul', 'span', 'p', 'pre').map(&:text).join(' ')
    from, to = body.scan(DATE_REG).map {|d| DateTime.parse(d.join()) }
    event = {
      title: root.search('h1').text,
      websource: page.uri.hostname,
      body: body,
      from_date: from,
      to_date: to,
      image: image_full_path(page, data[:image], root.search('h1').text)
    }
    record(data.merge(event))
  end

  def image_full_path(page, image, file_name)
    file_name = file_name.downcase.gsub(/\W/, '_') 
    image_url = URI.parse(image.src).scheme ? image.src : "#{page.uri.scheme}://#{page.uri.host}/#{image.src}"
    image_url = image_url.split('?').first
    image.fetch.save Rails.root.join('app/assets/images/', file_name)
    file_name
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
