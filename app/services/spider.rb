class Spider < BaseSpider
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
end
