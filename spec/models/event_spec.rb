require 'rails_helper'

describe Event do
  let(:event) { create(:event) }

  it "is valid with valid attributes" do
    event.title = "Anything"
    event.body = "Anything"
    event.image = "image src url"
    event.websource = "some site"
    event.source = "some source"
    event.from_date = DateTime.now
    event.to_date = DateTime.now + 1.week
    expect(event).to be_valid
  end

  it "is not valid without a title" do
    event.title = nil
    expect(event).to_not be_valid
  end

  it "is not valid without a body" do
    event.body = nil
    expect(event).to_not be_valid
  end

  it "is not valid without a websource" do
    event.websource = nil
    expect(event).to_not be_valid
  end

  it "is not valid without a image" do
    event.image = nil
    expect(event).to_not be_valid
  end

  it "is not valid without a source" do
    event.source = nil
    expect(event).to_not be_valid
  end
  
  it "is not valid without a site" do
    event.site = nil
    expect(event).to_not be_valid
  end

  context '#search' do
    it "return search results" do
      events = create_list(:event, 5)
      expect(Event.search('Euismod', nil, nil, nil).length).to eq(5)
    end
  end
end
