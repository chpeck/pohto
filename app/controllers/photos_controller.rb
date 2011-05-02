class PhotosController < ApplicationController
  def index
    key = params[:album_id].split("-")
    @photos = Photo.by_date(:startkey=>key.dup.push({}), :endkey=>key, :include_docs=>true, :reduce=>false, :descending=>true)
  end

  def show 
    send_file Photo.get(params[:id]).file["path"]
  end
end
