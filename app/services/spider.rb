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
      enqueue(root.attributes['href'].value, :process_articles, { image: img.src }) if root.attributes['href'].value
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
      image: image_full_path(page, data[:image])
    }
    record(data.merge(event))
  end

  def image_full_path(page, image)
    # Not able to get this working on HEROKU, hence using site image urls
    # path = image.fetch.save Rails.root.join('assets/images/', 'file_name')
    URI.parse(image).scheme ? image : "#{page.uri.scheme}://#{page.uri.host}/#{image}"
  end
end
