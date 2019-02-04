FactoryBot.define do
  # event factory with a `belongs_to` association for the Site
  factory :event do
    sequence(:id)    { |n| "#{n}" }
    title            { 'Euismod Malesuada Fringilla Porta Nibh' }
    body             { 'Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Nullam id dolor id nibh ultricies vehicula ut id elit.' }
    websource        { 'Some websource' }
    image            { 'image src url' }
    source           { 'Event source url' }
    from_date        { 3.months.ago }
    to_date          { 2.months.ago }
    association :site, factory: :site
  end
end
