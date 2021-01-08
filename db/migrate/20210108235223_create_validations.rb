class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations do |t|
      t.string :filename
      t.string :url
      t.string :state
      t.binary :result
      t.string :csv_id
      t.string :parse_options

      t.timestamps null: false
    end
  end
end
