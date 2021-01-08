class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :url
      t.string :dataset
      t.string :type

      t.timestamps null: false
    end
  end
end
