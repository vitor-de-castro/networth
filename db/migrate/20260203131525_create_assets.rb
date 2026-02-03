class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :name
      t.decimal :value, precision: 10, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
