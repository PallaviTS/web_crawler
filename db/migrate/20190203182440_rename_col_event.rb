class RenameColEvent < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :category, :source
  end
end
