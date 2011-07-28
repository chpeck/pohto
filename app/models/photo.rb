require 'find'

class Photo < CouchRest::Model::Base
  COUCHDB_URL = ENV['CLOUDANT_URL'] || 'http://localhost:5984'
  use_database CouchRest::Server.new(COUCHDB_URL).database!(Rails.env.production? ? "pohto" : "pohto_#{Rails.env}")
  property :file, Hash
  property :exif, Hash

  property :thumbnail_file_name, String
  property :thumbnail_content_type, String
  property :thumbnail_file_size, Integer
  property :thumbnail_updated_at, String
  has_attached_file :thumbnail, :styles => {:original => '1024x1024>', :medium => '800x800>', :thumbnail => '100x100#'}, :storage => :couch, :url => ":couch_url"
  timestamps!


  view_by(:date, :map => "function(doc) {
          if(doc['couchrest-type'] == 'Photo') {
            var date = doc['exif']['date_time_original'] || doc['created_at'];
            emit(date.match(/\\d+/g));
          }
  }", :reduce => "_count")

  def self.import_file(path)
    return if FileTest.size(path).zero?
    begin
      doc = self.new("_id" => Digest::MD5.hexdigest(File.read(path)))
      doc.file = {:path => path, :ctime => File.ctime(path)}
      exif = EXIFR::JPEG.new(path).to_hash 
      exif[:date_time_original] = exif[:date_time_original].iso8601 if exif[:date_time_original]
      doc.exif = exif.slice(:width, :height, :comment, :date_time_original, :orientation, :user_comment) rescue nil
      doc.thumbnail = open(path)
      doc.save            
    rescue RestClient::Conflict
      puts "#{doc.file[:path]} already in db. Clashes with #{Photo.get(doc.id).file['path']}"
    rescue EXIFR::MalformedJPEG
      puts "Skipping #{doc.file[:path]} not JPEG"
    end
  end

  def self.import_dir(path)
    Find.find(path) do |p|
      if FileTest.directory?(p)
        if File.basename(p)[0] == ?.
          Find.prune
        else
          next
        end
      else
        import_file(p)
      end 
    end
  end

end
