class Site < ApplicationRecord
  validates_presence_of :url
  validates_format_of :url, :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix, message: 'Not Valid URL'

  def self.crawl(data)
    spider = Spider.new({root: data['url'], handler: :process_index}, {max_url: data['max_url'].to_i, interval: data['interval'].to_i })
    spider.crawl
    # Bulk import
    Event.import spider.results.flatten
  end
end
