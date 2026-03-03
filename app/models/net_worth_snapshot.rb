class NetWorthSnapshot < ApplicationRecord
  belongs_to :user

  validates :total_value, presence: true, numericality: true
  validates :date, presence: true, uniqueness: { scope: :user_id }

  scope :for_user, ->(user) { where(user: user).order(date: :asc) }
  scope :recent, ->(days = 30) { where('date >= ?', days.days.ago) }
end
