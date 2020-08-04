class CountriesController < ApplicationController
  before_action :set_country, only: :show

  def show
    @starting_city ||= City.new
  end

  private

  def set_country
    @country ||= Country.find_by_name(params[:name])
  raise ActiveRecord::NotFound unless @country
  end
end
