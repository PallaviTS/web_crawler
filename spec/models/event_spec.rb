require 'rails_helper'

describe Event do
  subject { described_class.new }

  it "is valid with valid attributes" do
    subject.title = "Anything"
    subject.body = "Anything"
    subject.from_date = DateTime.now
    subject.to_date = DateTime.now + 1.week
    expect(subject).to be_valid
  end

  it "is not valid without a title" do
    expect(subject).to_not be_valid
  end

  it "is not valid without a body" do
    subject.title = "Anything"
    expect(subject).to_not be_valid
  end

  it "is not valid without a from_date" do
    subject.title = "Anything"
    subject.body = "Lorem ipsum dolor sit amet"
    expect(subject).to_not be_valid
  end

  it "is not valid without a to_date" do
    subject.title = "Anything"
    subject.body = "Lorem ipsum dolor sit amet"
    subject.from_date = DateTime.now
    expect(subject).to_not be_valid
  end
end
