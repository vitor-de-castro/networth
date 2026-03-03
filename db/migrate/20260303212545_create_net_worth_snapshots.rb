class CreateNetWorthSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :net_worth_snapshots do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_value, precision: 15, scale: 2, null: false
      t.date :date, null: false

      t.timestamps
    end
    # Ensure only one snapshot per user per day
    add_index :net_worth_snapshots, [:user_id, :date], unique: true

  end
end
