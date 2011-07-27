namespace :import do
  desc 'Import Photos from this directory'
  task :directory, :path do |cmd, args|
    Rake::Task[:environment].invoke
    Photo.import(args[:path])
  end

  desc 'watch the directory for new files'
  task :watch, :path do |cmd, args|
    begin
      pwd = Dir.pwd
      Dir.chdir(args[:path])
      Guard.setup
      Guard.start(:guardfile_contents => "
      guard 'importer' do 
        watch(%r{.*})
      end
      ")
    ensure
      Dir.chdir(pwd)
    end
  end

end
