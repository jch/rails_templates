require 'bundler'
Bundler.require(:default, :test)

require 'minitest/autorun'

# Code Path for Rails::Generators::AppGenerator
#   railtie/bin/rails
#   rails/cli
#   rails/commands/application.rb
#   AppGenerator.start
#   parse ARGV, instantiates AppGenerator
#   generator.invoke_all (thor group)
require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'fileutils'

class MiniTest::Unit::TestCase
  include FSTest

  attr_accessor :ask_stubs

  def setup
    @ask_stubs = {}
  end

  def teardown
    @ask_stubs = nil
  end

  # returns absolute path to a given template name
  #
  #   template_path('backup.rb')
  #   => /Users/projects/jch/rails-templates/templates/backup.rb
  def template_path(basename)
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates', basename))
  end

  # generate an app with a given template, and return the output
  #
  #  output = generate_app('backup.rb')
  #  assert_match /something/, output[0]
  def generate_app(template, name = 'foo')
    generator = Rails::Generators::AppGenerator.new([name], :template => template_path(template))
    capture_io do
      generator.invoke_all
    end
  end

  # Ewwwwww
  def stub_ask(pattern = "", result = "")
    @ask_stubs[pattern] = result
    code = <<-CODE
      def ask(pattern, color = nil)
        case pattern
        <% @ask_stubs.each do |patt,res| %>
        when Regexp.new(%q(<%= pattern %>))
          %q(<%= res %>)
        <% end %>
        else
          ""
        end
      end
    CODE
    code = ERB.new(code).result(binding)
    Thor::Shell::Basic.class_eval(code)
  end
end
