require 'test_helper'

class BackupTest < MiniTest::Unit::TestCase
  def setup
    super
    FileUtils.rm_rf 'foo'
  end

  def test_backup_default
    stub_ask
    output = generate_app('backup.rb')
    assert_match /backup generate/, output[0]
    assert_match(/ Backup/, output[0])  # readme should be printed
    

    assert_file "config/backup.rb" do |content|
      assert_match /PostgreSQL/, content
      assert_match /Gzip/, content
      assert_match /S3/, content
    end

    assert_file "README" do |content|
      refute_match(/ Backup/, content)
    end
  end

  def test_backup_mysql
    stub_ask("default: postgresql", "mysql")
    output = generate_app('backup.rb')
    assert_file "config/backup.rb" do |content|
      assert_match /MySQL/, content
    end
  end

  def test_add_to_readme
    stub_ask("README", "README")
    output = generate_app('backup.rb')
    assert_file "README", do |content|
      assert_match(/ Backup/, content)
    end
  end
end
