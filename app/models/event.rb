class Event < ApplicationRecord

  def self.search(str)
    Event.where("body ilike '%#{str}%'").uniq
  end
end
