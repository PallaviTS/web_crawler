class ChangeColName < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :dates, :date
  end
end
