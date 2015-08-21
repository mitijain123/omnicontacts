# omnigroupcontacts

Inspired by the popular OmniContacts, OmniGroupContacts is a library that enables users of an application to import contacts
from their email accounts with respect to group. The email providers currently supported are Gmail.
OmniGroupContacts is a Rack middleware, therefore you can use it with Rails, Sinatra and any other Rack-based framework.

OmniGroupContacts uses the OAuth protocol to communicate with the contacts provider.
In order to use OmniGroupContacts, it is therefore necessary to first register your application with the provider and to obtain client_id and client_secret.

## Usage

Add OmniGroupContacts as a dependency:

```ruby
gem "omnigroupcontacts"

```

As for OmniAuth, there is a Builder facilitating the usage of multiple contacts importers. In the case of a Rails application, the following code could be placed at `config/initializers/omnigroupcontacts.rb`:

```ruby
require "omnigroupcontacts"

Rails.application.middleware.use OmniGroupContacts::Builder do
  importer :gmailgroup, "client_id", "client_secret", {:redirect_path => "/oauth2callback", :ssl_ca_file => "/etc/ssl/certs/curl-ca-bundle.crt"}
  
end

```

## Register your application

* For Gmail : [Google API Console](https://code.google.com/apis/console/)


## Integrating with your Application

To use the Gem you first need to redirect your users to `/group_contacts/:importer`, where `:importer` can be gmailgroup.
No changes to `config/routes.rb` are needed for this step since omnigroupcontacts will be listening on that path and redirect the user to the email provider's website in order to authorize your app to access his contact list.
Once that is done the user will be redirected back to your application, to the path specified in `:redirect_path`.
If nothing is specified the default value is `/group_contacts/:importer/callback` (e.g. `/group_contacts/gmailgroup/callback`). This makes things simpler and you can just add the following line to `config/routes.rb`:

```ruby
  match "/group_contacts/:importer/callback" => "your_controller#callback"
```

The list of contacts can be accessed via the `omnigroupcontacts.contacts` key in the environment hash and it consists of a simple array of hashes.
The following table shows which fields are supported by which provider:

<table>
	<tr>
		<th>Provider</th>
		<th>:email</th>
		<th>:id</th>
		<th>:profile_picture</th>
		<th>:name</th>
		<th>:first_name</th>
		<th>:last_name</th>
		<th>:address_1</th>
		<th>:address_2</th>
		<th>:city</th>
		<th>:region</th>
		<th>:postcode</th>
		<th>:country</th>
		<th>:phone_number</th>
		<th>:birthday</th>
		<th>:gender</th>
		<th>:relation</th>
	</tr>
	<tr>
		<td>Gmail</td>
		<td>X</td>
		<td>X</td>
		<td></td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
		<td>X</td>
	</tr>
</table>

Obviously it may happen that some fields are blank even if supported by the provider in the case that the contact did not provide any information about them.

The information for the logged in user can also be accessed via 'omnigroupcontacts.user' key in the environment hash. It consists of a simple hash which includes the same fields as above.

The following snippet shows how to simply print name and email of each contact, and also the the name of logged in user:
```ruby
def contacts_callback
  @contacts = request.env['omnigroupcontacts.contacts']
  @user = request.env['omnigroupcontacts.user']
  puts "List of contacts of #{@user[:name]} obtained from #{params[:importer]}:"
  @contacts.each do |group_name, contacts|
  	puts "Group: #{contacts}"
  	contacts.each do |contact|
    	puts "Contact found: name => #{contact[:name]}, email => #{contact[:email]}"
    end
  end
end
```

If the user does not authorize your application to access his/her contacts list, or any other inconvenience occurs, he/she is redirected to `/contacts/failure`. The query string will contain a parameter named `error_message` which specifies why the list of contacts could not be retrieved. `error_message` can have one of the following values: `not_authorized`, `timeout` and `internal_error`.

## License

Copyright (c) 2015 Mitesh Jain

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
