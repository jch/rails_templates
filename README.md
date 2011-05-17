# Rails Template

An extraction of common tasks I do when I create a new Rails project.

# Usage

For a new project:

    rails new myapp -m https://github.com/jch/rails_templates/raw/master/rails.template

For an existing project:

    rake rails:template LOCATION=https://github.com/jch/rails_templates/raw/master/rails.template

# Overview

The template does the following:

* adds commonly used gems
* setup my preferred test_helper
* remove prototypejs
* conditionally add Hoptoad
* initialize local git repository
* conditionally add to github
* conditionally add to heroku

# Github Setup

In order to create new projects to Github, you'll need to save your
Github API token to ~/.github_token. You can find your API token at
your [Account Admin page](https://github.com/account/admin). I also
recommend changing the permissions to that file to 600.

    chmod 600 ~/.github_token

Whenever you change your password, you'll have to update your API
token.

# Heroku Setup

In order to automatically add projects to Heroku, you'll need to have
the heroku gem installed before you run the templates:

    gem install heroku

The script will prompt you for an application name. If the heroku app
was successfully created, a 'heroku' remote will be added for
you. However, if the app failed to create, no remote repo will be
added and you'll need to do it manually yourself.

# Resources

I learned about Rails application templates through a variety of
resources. I recommend reading through all of them because they all
have their own useful tidbits.  Here's a list of links:

* [Creating and Customizing Rails Generators & Templates](http://guides.rubyonrails.org/generators.html)
* [Thor Actions](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html) - usable in your templates
* [Application Templates in Rails 3 by Ben Scofield](http://benscofield.com/2009/09/application-templates-in-rails-3/)
* [Rails Templates by Pratik Naik](http://m.onkey.org/rails-templates)

