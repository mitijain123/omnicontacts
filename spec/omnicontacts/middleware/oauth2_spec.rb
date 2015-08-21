require "spec_helper"
require "omnigroupcontacts/middleware/oauth2"

describe OmniGroupContacts::Middleware::OAuth2 do

  before(:all) do
    class OAuth2Middleware < OmniGroupContacts::Middleware::OAuth2
      def authorization_url
        "http://www.example.com"
      end

      def redirect_path
        "/redirect_path"
      end

      def self.mock_session
        @mock_session ||= {}
      end

      def session
        OAuth2Middleware.mock_session
      end

      def fetch_access_token code
        ["access_token", "token_type", "token_refresh"]
      end

      def fetch_contacts_using_access_token token, token_type
        [{:name => "John Doe", :email => "john@example.com"}]
      end
    end
  end

  let(:app) {
    Rack::Builder.new do |b|
      b.use OAuth2Middleware, "client_id", "client_secret"
      b.run lambda { |env| [200, {"Content-Type" => "text/html"}, ["Hello World"]] }
    end.to_app
  }

  context "visiting the listening path" do
    it "should redirect to authorization site when visiting the listening path" do
      get "#{ MOUNT_PATH }oauth2middleware"
      last_response.should be_redirect
      last_response.headers['location'].should eq("http://www.example.com")
    end

    it "should pass through state query params visiting the listening path" do
      get "#{ MOUNT_PATH }oauth2middleware?state=/parent/resource/id"
      last_response.headers['location'].should eq("http://www.example.com?state=/parent/resource/id")
    end
  end

  context "visiting the callback url after authorization" do
    it "should fetch the contacts" do
      get '/redirect_path?code=ABC'
      last_response.should be_ok
      last_request.env["omnigroupcontacts.contacts"].size.should be(1)
    end

    it "should redirect to failure page because user did not allow access to contacts list" do
      get '/redirect_path?error=not_authorized'
      last_response.should be_redirect
      last_response.headers["location"].should eq("#{ MOUNT_PATH }failure?error_message=not_authorized&importer=oauth2middleware")
    end
  end
end
