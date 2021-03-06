class Spider < BaseSpider
  def process_index(page, data = {})
    # Traverse all page links e.g /?page=1, /?events=1
    page.links_with(href: LINK_REG).each do |link|
      unless disallowed?(link.href)
        enqueue(redirected_url(link.href), :process_index, data)
      end
    end
    
    # Starting with img tag, to get to article's page
    page.images_with(src: IMG_REG).each do |img|
      root = page.xpath("//img[@src='#{img.src}']").first
      while root.node_name != 'a' && root.respond_to?(:parent)
        root = root.parent
      end
      root_link = root.attributes['href'].value
      if root_link && !disallowed?(root_link)
        enqueue(redirected_url(root_link), :process_articles, data.merge({ image: img.src }))
      end
    end
  end

  def process_articles(page, data = {})
    # Find the article title
    h1 = page.search('h1').first
    return unless h1
    
    # Find the common parent for <h1> and all <p>s.
    root = h1
    while root.node_name != 'body' && root.search('p').count < 5
      root = root.parent
    end

    # Fetch useful tags and scan for dates
    body = root.search('h1', 'nav', 'ul', 'span', 'p', 'pre').map(&:text).join(' ')
    from, to = nil
    ['%d%m%y', '%Y%m%d'].each do |format|
      begin
        from, to = body.scan(DATE_REG).map { |d| DateTime.strptime(d.join(), format) }.uniq
      rescue
        next
      end
    end

    # Event saved as hash
    event = {
      title: root.search('h1').text,
      websource: page.uri.hostname,
      source: page.uri.to_s,
      body: body,
      from_date: from,
      to_date: to,
      image: image_full_path(page, data[:image]),
      site_id: data[:site_id]
    }

    # Push to [], save as bulk import
    record(data.merge(event))
  end

  def image_full_path(page, image)
    # Not able to get this working on HEROKU, hence using site image urls
    # path = image.fetch.save Rails.root.join('assets/images/', 'file_name')
    URI.parse(image).scheme ? image : "#{page.uri.scheme}://#{page.uri.host}/#{image}"
  end
end
