class Site < ApplicationRecord
  validates_presence_of :url
  validates_format_of :url, :with => /\A(http|https):\/\/(.*)\z/ix, message: 'Not Valid URL'

  def self.crawl(data)
    spider = Spider.new({root: data['url'], handler: :process_index}, {max_url: data['max_url'].to_i, interval: data['interval'].to_i })
    spider.crawl
    Event.import spider.results
    { results: spider.results, errors: spider.errors }
  end
end
