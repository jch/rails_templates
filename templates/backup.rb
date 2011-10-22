# Backup Rails Database
#
# Assumptions
# * config/database.yml exists and is configured for RAILS_ENV
# * config/s3.yml exists and has access id and secret access key

# Add gem dependency to https://github.com/meskyanichi/backup
gem 'backup', :version => '3.0.15'
gem 'fog', :version => '0.7.2'  # used by backup for s3 uploads, but not a dependency

run "bundle --quiet"

db = ask("'postgresql' or 'mysql'? [default: postgresql]")
db = db.blank? ? 'postgresql' : db
run "backup generate --databases='#{db}' --storages='s3' --compressors='gzip' --path=."
run "mv config.rb config/backup.rb"

# Add rake backup tasks
# TODO: these should be in erb templates
file 'lib/tasks/backup.rake', <<-RAKETASK
namespace :backup do
  desc "Run backups"
  task :default do
    system('backup perform -t my_backup -c config/backup.rb')
  end

  desc "Restore backup. BACKUP=/full/path/to/backup.gz"
  task :restore do
    
  end

  desc "List current available backups"
  task :list => :environment do
    s3 = YAML.load(File.read(File.join(Rails.root, 'config', 's3.yml')))
    s3.symbolize_keys!
    conn = Fog::Storage.new(:provider => 'AWS', aws_access_key_id: s3[:aws_access_key_id], aws_secret_access_key: s3[:aws_secret_access_key])
    dir = conn.directories.select {|d| d.key == "myapp-key"}  # TODO: read appropriate key
    dir.files.each do |file|
      puts file.key
    end
  end
end
RAKETASK


help = <<-HELP

# Backups

Configuration for backups are in config/backup.rb

To create a new backup, run:

    rake backup

To see existing backups, run:

    rake backup:list

To restore an existing backup, run:

    rake backup:restore BACKUP=full/path/to/backup.gz

HELP
filename = ask("README filename to append instructions to? [default: none]")
if !filename.blank?
  append_to_file(filename, help)
end
puts help