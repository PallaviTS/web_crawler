class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.text :title
      t.string :websource
      t.datetime :dates
      t.text :body
      t.string :category
      t.string :image

      t.timestamps
    end
  end
end
