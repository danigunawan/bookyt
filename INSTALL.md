We currently support installing on Debian 5.0 Lenny and Ubuntu 12.04
systems.

Install Ruby’n’Rails
--------------------

Bookyt is developed and tested using Rails 3.2 and Ruby 2.2.

Install packages needed:

    sudo apt-get install rubygems irb libruby-extras libxml2-dev libxslt-dev ruby-dev build-essential
    sudo apt-get install git

Then some gems:

    sudo gem install rake bundler

Testing
-------

You currently need phantomjs version 1.8.1 or newer. You can get this on
Ubuntu 13.10.

Install Bookyt
--------------

Install current Bookyt from git repository. We’ll use this checkout as
working directory from now on:

    git clone http://github.com/huerlisi/bookyt.git
    cd bookyt

Install dependency gems:

    bundle

Setup database:

Copy database.yml.example to database.yml and edit as needed.

    cp config/database.yml.example config/database.yml

Initialize the database:

    bundle exec rake db:setup

Configure
---------

There's some settings that are done on an application level like application title and API
keys for external services. These are configured in config/application.yml.

To get started copy the example:

    cp config/application.yml.example config/application.yml
    
### Authentcation

You can decide between two authentication mechanisms: Database Authentication, `database_authenticatable` (default) and CAS Authentication `cas_authenticatable`.

##### Database Authentication

For Database Authentication, no changes are needed.

##### CAS Authentication

If you go for CAS Authentication, set `devise_backend` to `cas_authenticatable` and make sure to set `cas_base_url`.

To handle the extra attributes, add a class named `CASExtraAttributesMapper` which responds to `.call`. For example:

```ruby
class CASExtraAttributesMapper
  def self.call(extra_attributes, user)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :full_name
        user.fullname = value
      when :roles
        user.role_texts = [value.split(',')].flatten
      end
      # And so on for other attributes
    end
  end
end
```

Setup admin user
----------------

There’s a rake task to setup an admin user:

    bundle exec rake users:admin

Create account types
--------------------

Account types need to be named correctly for calculation of the balance
sheet and profit sheet.

See db/seeds/locales for your convenience.

### Run

You should now be able to start Bookyt:

    rails server

Bookyt is now available at http://localhost:3000

Enjoy!
