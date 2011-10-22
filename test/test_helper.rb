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

module RailsTemplate
  extend self

  # clean the tmp dir between tests
  # TODO: ideally we want to use FakeFS here, but we can't use it because
  # Thor forks child processes to complete actions, and FakeFS has no effect
  # on forked processes. For now, we're manually removing the dir after test
  def wipe_tmp!
    Dir.glob("tmp/*").each do |path|
      FileUtils.rm_rf path
    end
  end
end

at_exit { RailsTemplate.wipe_tmp! }

class MiniTest::Unit::TestCase
  include FSTest

  # hash keyed by pattern of question asked by thor, with value as answer for
  # question.
  attr_accessor :ask_stubs

  def setup
    @ask_stubs = {}
    RailsTemplate.wipe_tmp!
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
  #
  # Returns tuple of STDOUT, and STDERR
  def generate_app(template, name = 'fixture_app')
    generator = Rails::Generators::AppGenerator.new(["tmp/#{name}"], :template => template_path(template))
    capture_io do
      generator.invoke_all
    end
  end

  # When generating an app, the :ask method is used to prompt the user for
  # input on choices.
  # To stub all :ask methods with blank answers, call stub_ask with no arguments
  # To a specific question, provide a string pattern for the question, and the
  # answer that should be given.
  # TODO: this seems kind of gross
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
