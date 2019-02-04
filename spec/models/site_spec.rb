require 'rails_helper'

describe Site do
  let(:site) { create(:site) }

  it "is valid with valid attributes" do
    site.url = "https://www.co-berlin.org/en/calender"
    site.max_url = 1000
    site.interval = 2
    expect(site).to be_valid
  end

  it "is not valid without a url" do
    site.url = nil
    expect(site).to_not be_valid
  end

  it "is not valid for invalid url" do
    site.url = 'berlin.org/en/calender'
    expect(site).to_not be_valid
  end

  context '#crawl' do
    it "return results" do
      allow(Site).to receive(:crawl).and_return({ results: [], errors: [] })
      expect(Site.crawl({ url: 'https://www.co-berlin.org/en/calender' })).to eq({ results: [], errors: [] })
    end
  end

end
