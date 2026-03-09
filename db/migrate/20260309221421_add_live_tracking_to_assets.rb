class AddLiveTrackingToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :quantity, :decimal, precision: 20, scale: 8
    add_column :assets, :symbol, :string
    add_column :assets, :track_live, :boolean, default: false
  end
end
