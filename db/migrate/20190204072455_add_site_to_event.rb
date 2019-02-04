class AddSiteToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :site_id, :integer
  end
end
