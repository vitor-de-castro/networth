class CurrenciesController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(currency: params[:currency])
      redirect_to root_path, notice: "Currency updated to #{params[:currency]}"
    else
      redirect_to root_path, alert: "Invalid currency"
    end
  end
end
