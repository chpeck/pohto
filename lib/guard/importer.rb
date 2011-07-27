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
      abs_paths = paths.collect {|path| File.join(Dir.pwd, path) }
      puts "Run On Change : #{abs_paths}"
    end
  end
end