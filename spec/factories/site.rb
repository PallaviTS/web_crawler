FactoryBot.define do
  factory :site do
    sequence(:id) { |n| "#{n}" }
    sequence(:url) { |n| "https://www.co-berlin.org/en/calender#{n}" }
    max_url   { 1000 }
    interval  { 2 }
  end
end
