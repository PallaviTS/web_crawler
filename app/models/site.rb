class Site < ApplicationRecord
  # Using delete_all, to avoid n+1 query, no callbacks
  has_many :events, dependent: :delete_all
  validates_presence_of :url
  validates_format_of :url, :with => /\A(http|https):\/\/(.*)\z/ix, message: 'Not Valid URL'
  before_create :destroy_if_exists

  def self.crawl(data)
    # Calling Service class to scrape data
    spider = Spider.new({ root: data['url'], handler: :process_index }, { max_url: data['max_url'].to_i, interval: data['interval'].to_i, site_id: data[:site_id] })
    spider.crawl
    # Bulk import data
    # Minimal number of SQL insert statements 
    Event.import spider.results
    { results: spider.results, errors: spider.errors }
  end

  # Destroy site and its events, if new url to crawl is already scrapped
  def destroy_if_exists
    scrapped_site = Site.find_by_url(url)
    scrapped_site.destroy if scrapped_site
  end
end
