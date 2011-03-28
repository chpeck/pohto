class AlbumsController < ApplicationController
  def index
    @albums = Photo.by_date(:start_key=>[], :descending=>true, :group_level=>3, :reduce=>true)["rows"]
  end
end
