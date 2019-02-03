FactoryBot.define do
  factory :event do
    sequence(:id) { |n| "#{n}" }
    sequence(:title) { |n| "#{n} Euismod Malesuada Fringilla Porta Nibh" }
    body   { 'Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Nullam id dolor id nibh ultricies vehicula ut id elit.' }
    from_date  { 3.months.ago }
    to_date    { 2.months.ago }
  end
end
