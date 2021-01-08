class CreateSummaries < ActiveRecord::Migration
  def change
    create_table :summaries do |t|
      t.integer :sources
      t.string :states
      t.string :hosts
      t.string :errors_breakdown
      t.string :warnings_breakdown
      t.string :info_messages_breakdown
      t.string :structure_breakdown
      t.string :schema_breakdown
      t.string :context_breakdown

      t.timestamps null: false
    end
  end
end
