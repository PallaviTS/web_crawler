class Event < ApplicationRecord

  def self.search(body, websource, from_date, to_date)
    where("#{build_filter_clause(body, websource, from_date, to_date)}")
    .select(:body, :websource, :from_date, :to_date)
    #where('websource = ?', "#{websource}") if websource.present?
    #where('body ilike ?', "%#{body}%") if body.present?
    #where('from_date between ? AND ?', "#{from_date}", "#{to_date}") if from_date.present? && to_date.present?
    #where('to_date between ? AND ?', "#{from_date}", "2019-12-31") if from_date.present?
    #where('to_date between ? AND ?', "2008-12-18", "#{to_date}") if to_date.present?
  end

  def self.build_filter_clause(body, websource, from_date, to_date)
    filter_clause  = "websource = '#{websource}' and " if websource.present?
    filter_clause += "body ilike '%#{body}%' and " if body.present?
    if from_date.present? && to_date.present? 
      filter_clause += "from_date BETWEEN  #{from_date} AND #{to_date} or to_date BETWEEN #{from_date} AND #{to_date}"
    end
    filter_clause += "from_date BETWEEN  '#{from_date}' AND '2020-03-19'" if from_date.present?
    filter_clause += "to_date BETWEEN  '2009-03-19' AND '#{to_date}'" if to_date.present?
  end
end
