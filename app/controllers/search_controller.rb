class SearchController < ApplicationController
  def search
    if params[:query]
      raise params.inspect
    end
  end
end
