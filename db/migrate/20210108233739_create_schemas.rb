class CreateSchemas < ActiveRecord::Migration
  def change
    create_table :schemas do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
