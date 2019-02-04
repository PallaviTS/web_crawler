desc "This task is called by the Heroku scheduler add-on"
task :crawl => :environment do
  ['https://gorki.de/en/programme/2018/08/all', 'https://www.co-berlin.org/en/calender'].each do |url|
    puts "Crawling...#{url}"
    site = Site.create({ url: url })
    if site.save
      spider = Spider.new({ root: site.url, handler: :process_index }, { site_id: site.id })
      spider.crawl
      Event.import spider.results
      Rails.logger.info "********"
      Rails.logger.info spider.results.length
      Rails.logger.info spider.errors.length 
      Rails.logger.info "********"
    end
    puts "Done Crawling...#{url}"
  end
end
