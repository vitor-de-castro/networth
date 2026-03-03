class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :assets, dependent: :destroy
  has_many :net_worth_snapshots, dependent: :destroy

  CURRENCIES = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD'].freeze

  validates :currency, inclusion: { in: CURRENCIES }, allow_nil: true
end
