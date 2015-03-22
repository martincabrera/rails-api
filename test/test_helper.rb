ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'


class ActiveSupport::TestCase
  Minitest::Reporters.use!
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def json(body)
    JSON.parse(body, symbolize_names: true)
  end

  def encode_credentials(name, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(name, password)
  end

end