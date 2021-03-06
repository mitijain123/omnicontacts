require "spec_helper"
require "omnigroupcontacts"
require "omnigroupcontacts/middleware/base_oauth"

describe OmniGroupContacts::Middleware::BaseOAuth do
  
  before(:all) do 
    class TestProvider < OmniGroupContacts::Middleware::BaseOAuth
      def initialize app, consumer_key, consumer_secret, options = {}
        super app, options
      end
      
      def redirect_path
        "#{ MOUNT_PATH }testprovider/callback"
      end
    end
    omnigroupcontacts.integration_test.enabled = true
  end

  let(:app) {
    Rack::Builder.new do |b|
      b.use TestProvider, "consumer_id", "consumer_secret"
      b.run lambda { |env| [200, {"Content-Type" => "text/html"}, ["Hello World"]] }
    end.to_app
  }
  
  it "should return a preconfigured list of contacts" do
    omnigroupcontacts.integration_test.mock(:testprovider, :email => "user@example.com")
    get "#{ MOUNT_PATH }testprovider"
    get "#{ MOUNT_PATH }testprovider/callback"
    last_request.env["omnigroupcontacts.contacts"].first[:email].should eq("user@example.com")
  end

  it "should redurect to failure url" do
    omnigroupcontacts.integration_test.mock(:testprovider, "some_error" )
    get "#{ MOUNT_PATH }testprovider"
    get "#{MOUNT_PATH }testprovider/callback"
    last_response.should be_redirect
    last_response.headers["location"].should eq("#{ MOUNT_PATH }failure?error_message=internal_error&importer=testprovider")
  end
  
  it "should pass through state query params to the failure url" do
    omnigroupcontacts.integration_test.mock(:testprovider, "some_error" )
    get "#{MOUNT_PATH }testprovider/callback?state=/parent/resource/id"
    last_response.headers["location"].should eq("#{ MOUNT_PATH }failure?error_message=internal_error&importer=testprovider&state=/parent/resource/id")
  end
  
  after(:all) do 
    omnigroupcontacts.integration_test.enabled = false
    omnigroupcontacts.integration_test.clear_mocks
  end
  
end