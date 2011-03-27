require 'find'
require 'ostruct'

class Photo < CouchRest::Model::Base
  COUCHDB_URL = ENV['CLOUDANT_URL'] || 'http://127.0.0.1:5984'
  use_database CouchRest::Server.new(COUCHDB_URL).database!(Rails.env.production? ? "pohto" : "pohto_#{RAILS_ENV}")
  property :file, Hash
  property :exif, Hash
  timestamps!

  view_by(:date, :map => "function(doc) {
          if(doc['couchrest-type'] == 'Photo') {
            var date = doc['exif']['date_time_original'] || doc['created_at'];
            var parts = date.match(/\\d+/g);
            emit([parts[0], parts[1], parts[2]], doc);
          }
  }", :reduce => "_count")

  def self.import(path)
    Find.find(path) do |p|
      if FileTest.directory?(p)
        if File.basename(p)[0] == ?.
          Find.prune
        else
          next
        end
      else
        next if FileTest.size(p).zero?
        puts p.inspect
        begin
          doc = self.new("_id" => Digest::MD5.hexdigest(File.read(p)))
          doc.file = {:path => p, :ctime => File.ctime(p)}
          exif = EXIFR::JPEG.new(p).to_hash 
          exif[:date_time_original] = exif[:date_time_original].iso8601 if exif[:date_time_original]
          doc.exif = exif.slice(:width, :height, :comment, :date_time_original, :orientation, :user_comment) rescue nil
          puts doc.inspect
          doc.save            
        rescue RestClient::Conflict
          puts "#{doc.file[:path]} already in db. Clashes with #{Photo.get(doc.id).file['path']}"
        rescue EXIFR::MalformedJPEG
          puts "Skipping #{doc.file[:path]} not JPEG"
        end
      end 
    end
  end

end
