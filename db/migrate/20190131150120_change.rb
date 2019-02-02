class Change < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :date, :from_date
    add_column :events, :to_date, :datetime
  end
end
