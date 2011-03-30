class AlbumsController < ApplicationController
  def index
    @albums = Photo.by_date(:descending=>true, :group_level=>3, :reduce=>true)["rows"].collect do |row|
      { :date => row["key"].join("-"), :photo => Photo.by_date(:startkey => row["key"], :endkey => row["key"].dup.push([]), :reduce => false, :limit => 1).first }
    end
  end
end
