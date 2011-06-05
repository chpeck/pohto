class AlbumsController < ApplicationController
  def index
    options = { :descending=>true, :group_level=>3, :reduce=>true, :limit => 100 }
    options.merge!(:startkey => params[:start_key].split("-")) if params[:start_key]
    @albums = Photo.by_date(options)["rows"].collect do |row|
      { :date => row["key"].join("-"), :photo => Photo.by_date(:startkey => row["key"], :endkey => row["key"].dup.push([]), :reduce => false, :limit => 1).first }
    end

    render(:partial => "album", :collection => @albums, :locals => {:size => @albums.size}) && return if request.xhr?
  end
end
