desc "This task is called by the Heroku scheduler add-on"
task :crawl => :environment do
  ['https://gorki.de/en/programme/2018/08/all', 'https://www.co-berlin.org/en/calender'].each do |url|
    site = Site.create({ url: url })
    if site.save
      Rails.logger.info "Crawling...#{url}"
      
      # Build Options
      options = { site_id: site.id }
      options.merge({ max_url: site.max_url }) if site.max_url.present?
      options.merge({ interval: site.interval }) if site.interval.present?

      # Call Spider to crawl
      spider = Spider.new({ root: site.url, handler: :process_index }, options)
      spider.crawl

      Event.import spider.results
      
      # Print results
      Rails.logger.info "********"
      Rails.logger.info spider.results.length
      Rails.logger.info spider.errors.length 
      Rails.logger.info "********"
      Rails.logger.info "Done Crawling...#{url}"
    else
      Rails.logger.info site.errors.messages
    end
  end
end
