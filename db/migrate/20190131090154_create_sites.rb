class CreateSites < ActiveRecord::Migration[5.2]
  def change
    create_table :sites do |t|
      t.string :url
      t.integer :max_url
      t.integer :interval
      t.json :options

      t.timestamps
    end
  end
end
