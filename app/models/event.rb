class Event < ApplicationRecord
  belongs_to :site
  # after_destroy :remove_image
  validates_presence_of :title, :body, :websource, :image, :source

  def self.search(body, websource, from_date, to_date)
    # Build the filter clause based on attrs avaliable
    where("#{build_filter_clause(body, websource, from_date, to_date)}")
    .select(:id, :title, :body, :websource, :from_date, :to_date, :image, :source)
  end

  def self.build_filter_clause(title, websource, from_date, to_date)
    filter_clause    = ' true = true '
    filter_clause   += " and websource = '#{websource}'" if websource.present?
    filter_clause   += " and title ilike '%#{title}%' " if title.present?
    filter_clause   += " and (from_date BETWEEN  '#{from_date}' AND '#{to_date}' and 
                         to_date BETWEEN '#{from_date}' AND '#{to_date}')" if from_date.present? && to_date.present?
    filter_clause   += " and from_date >= '#{from_date}'" if from_date.present?
    filter_clause   += " and to_date <= '#{to_date}'" if to_date.present?
    filter_clause
  end

  # Not able to get this working on HEROKU, reason: storage -> s3 setup
  def remove_image
    image_path = Rails.root.join('app/assets/images', image)
    if File.exist?(image_path)
      Rails.logger.info 'Image deleted'
      File.delete(image_path)
    end
  end
    
end
