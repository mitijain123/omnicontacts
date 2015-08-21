module OmniGroupContacts
  
  VERSION = "0.3.8"

  MOUNT_PATH = "/group_contacts/"

  autoload :Builder, "omnigroupcontacts/builder"
  autoload :Importer, "omnigroupcontacts/importer"
  autoload :IntegrationTest, "omnigroupcontacts/integration_test"

  class AuthorizationError < RuntimeError
  end


  def self.integration_test
    IntegrationTest.instance
  end
  
end
