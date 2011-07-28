require 'guard'
require 'guard/guard'

module ::Guard
  class Importer < Guard
    def initialize(watchers = [], options = {})
      super
    end

    def start
      puts "Start"
    end

    def stop
      puts "Stop"
    end

    def reload
      puts "Reload"
    end

    def run_all
      puts "Run All"
    end

    def run_on_change(paths)
      paths.each do |path| 
        Photo.import_file(File.join(Dir.pwd, path))
      end
    end
  end
end