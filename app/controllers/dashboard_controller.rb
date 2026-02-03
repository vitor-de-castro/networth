class DashboardController < ApplicationController
  #before_action :authenticate_user!

  def index
    @assets = current_user.assets.order(created_at: :desc)
    @total_net_worth = current_user.assets.sum(:value)
  end
end
