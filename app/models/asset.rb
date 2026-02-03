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


end
