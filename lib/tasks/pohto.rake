namespace :import do
  desc 'Import Photos from this directory'
  task :directory, :path do |cmd, args|
    Rake::Task[:environment].invoke
    Photo.import(args[:path])
  end
end
