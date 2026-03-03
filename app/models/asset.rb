class Asset < ApplicationRecord
  belongs_to :user

  CATEGORIES = [
    'Bank Account',
    'Stocks',
    'Crypto',
    'Property',
    'Vehicle',
    'Collectible',
    'Other'
  ].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :name, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Create snapshot after asset is created, updated, or destroyed
  after_commit :create_net_worth_snapshot

  private

  def create_net_worth_snapshot
    total = user.assets.sum(:value)

    # Only create one snapshot per day
    snapshot = user.net_worth_snapshots.find_or_initialize_by(date: Date.today)
    snapshot.total_value = total
    snapshot.save
  end
end
