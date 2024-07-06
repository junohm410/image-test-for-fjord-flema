# frozen_string_literal: true

class ListedItemsController < ApplicationController
  def index
    @items = current_user.items
  end
end
