CouchRest::Model::Base.send(:include, Paperclip::Glue)

module Paperclip
  class << self
    def logger #:nodoc:
      @logger ||= Logger.new("#{Rails.root}/log/paperclip.log")
    end
  end
end

# we need to hack couchrest model because we need to resave a doc after attaching attachments without going into a loop from
# paperclip callbacks
module CouchRest
  module Model
    module Persistence
      def save_without_callbacks(options={})
        return false unless perform_validations(options)
        result = database.save_doc(self)
        result['ok'] == true
      end
    end
  end
end

module Paperclip
  module Storage
    module Couch
      def self.extended base
        base.instance_eval do
          if @path == self.class.default_options[:path]
            @path = ":attachment/:style/:basename.:extension"
          end

          if @url == self.class.default_options[:url]
            @url = ":couch_url"
          end
        end

        Paperclip.interpolates(:couch_url) do |attachment, style|
          "#{attachment.instance.attachment_url(attachment.path(style))}"
        end

        Paperclip.interpolates(:couch_uri) do |attachment, style|
          "#{attachment.instance.attachment_uri(attachment.path(style))}"
        end
      end

      def exists?(style_name = default_style)
        instance.has_attachment? path(style_name)
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file style = default_style
        return @queued_for_write[style] if @queued_for_write[style]
        if instance.has_attachment?(path(style))
          filename = path(style)
          extname  = File.extname(filename)
          basename = File.basename(filename, extname)
          file = Tempfile.new([basename, extname])
          file.binmode
          file.write instance.read_attachment(path(style))
          file.rewind
          return file
        else
          return nil
        end
      end
      
      def flush_writes #:nodoc:
        attachments_modified = false
        @queued_for_write.each do |style_name, file|
          log("saving #{path(style_name)} to CouchDB")

          if instance.has_attachment? path(style_name)
            instance.update_attachment(:name => path(style_name), :file => file)
          else
            instance.create_attachment(:name => path(style_name), :file => file)
          end          
          attachments_modified = true
        end

        if attachments_modified
          instance.save_without_callbacks 

          # because couchrest will re-encode attachment files every time it saves,
          # we set the stub to true so it skips them on subsequent saves with the same
          # instance
          @queued_for_write.each do |style_name, file|
            instance.attachments[path(style_name)]['stub'] = true            
          end
        end
          
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        attachments_modified = false
        @queued_for_delete.each do |path|
          begin
            if instance.has_attachment? path
              instance.delete_attachment(path)
              attachments_modified = true
            end
          rescue Exception => e
            log "Error trying to delete from CouchDB: #{e}"
          end
        end
        instance.save_without_callbacks if attachments_modified
        @queued_for_delete = []
      end
    end

  end
end

