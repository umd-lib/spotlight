# Application Creation

## Introduction

The “[projectblacklight/spotlight][spotlight-plugin]” repository is for the
“spotlight” gem, which is a plugin to Blacklight. The repository provides a
Rails application generator that is used to create a sample Rails application
that uses the “spotlight” gem.

## Application Creation Steps

This application was created using the Rails application generator in the
“[projectblacklight/spotlight][spotlight-plugin]” repository.

In the following procedure, the “projectblacklight/spotlight” repository is
checked out into a “spotlight-app-generator” directory, to enable a
“spotlight” Rails application to be created.

When generating the project, the “template.rb” file
(<https://github.com/projectblacklight/spotlight/blob/v3.5.0.3/template.rb>)
defaults to using the “projectblacklight/spotlight” GitHub repository as the
“spotlight” gem version in the “Gemfile” for the generated project, meaning
that whatever is the current commit on “main” branch of the
“projectblacklight/spotlight” is used (even if the checked out
“projectblacklight/spotlight” repository is set to a specific tag).

The following procedure includes steps to ensure the latest (as of March 1, 2024)
stable version of the “projectblacklight/spotlight” repository, v3.5.0.3
(which uses Blacklight v7) is used instead of the most recent commit on the
project "main" branch.

The project appears to be on the cusp of moving to Blacklight 8, and has several
“beta” version (currently the latest is “v3.6.0.beta7”). In experimenting with
the latest commit on the “main” branch, it was found that images are not
displayed on the item detail pages, which is recorded the following issue in the
“projectblacklight/spotlight” repository -
<https://github.com/projectblacklight/spotlight/issues/2992>

The following steps assumes “rvm” is being used.

1. In a base directory, checked out the “projectblacklight/spotlight” repository
   into a directory named “spotlight-app-generator”, and switched into the
  directory:

   ```zsh
   $ git clone https://github.com/projectblacklight/spotlight.git spotlight-app-generator
   $ cd spotlight-app-generator
   ```

2. Switched to the latest stable release, v3.5.0.3

    ```zsh
    $ git checkout v3.5.0.3
    ```

3. Installed Ruby 3.0.6:

    ```zsh
    $ rvm install 3.0.6 --with-openssl-dir=`brew --prefix openssl@1.1`
    ```

4. Created a “spotlight-app-generator” gemset:

    ```zsh
    $ rvm use ruby-3.0.6
    $ rvm gemset create spotlight-app-generator
    $ rvm use 3.0.6@spotlight-app-generator
    ```

5. Installed the latest “bundler” version, (“2.5.6” as of March 1, 2024):

    ```zsh
    $ gem install bundler --version 2.5.6
    ````

6. Installed the latest Rails 6.1.x version (“6.1.7.7” as of March 1, 2024).
   This was necessary to run the “spotlight” Rails application generator:

    ```zsh
    $ gem install rails --version 6.1.7.7
    ```

7. Switched back to the base directory:

    ```zsh
    $ cd ..
    ```

8. Set RVM to use the “3.0.6@spotlight-app-generator” gemset:

    ```zsh
    $ rvm use 3.0.6@spotlight-app-generator
    ```

9. Ran the Rails application generator, specifying the “SPOTLIGHT_GEM”
   environment variable to point to the “../spotlight-app-generator" directory
   to ensure that v3.5.0.3 of the “projectblacklight/spotlight” repository is
   used, instead of the latest commit in the “main” branch of the repository:

    ```zsh
    $ SKIP_TRANSLATION=1 SPOTLIGHT_GEM="../spotlight-app-generator/" rails new --skip-spring spotlight -m spotlight-app-generator/template.rb
    ```

   This created a “spotlight” subdirectory.

   When asked `Would you like to create an initial administrator?` answered `n`.

10. Switched into the “spotlight” subdirectory:

    ```zsh
    $ cd spotlight
    ```

11. Pinned the “blacklight-spotlight” gem to “v3.5.0.3”:

    11.1.  Edited the “Gemfile”:

    ```zsh
    $ vi Gemfile
    ```

    and changed the line:

    ```text
    gem 'blacklight-spotlight', path: '../spotlight-app-generator/'
    ```

    to

    ```text
    gem 'blacklight-spotlight', '= 3.5.0.3'
    ```

    11.2. Ran bundler to install the gem version:

    ```zsh
    $ bundle install
    ```

12. Set up then RVM Ruby/gemset configuration files:

    12.1. Created “.ruby-version” and “.ruby-gemset” files to specify the Ruby
          and gemset to use with RVM:

    ```zsh
    $ printf "ruby-3.0.6\n" > .ruby-version
    $ printf "spotlight\n" > .ruby-gemset
    ```

    12.2. Switched out of the directory and back in to enable RVM to configure
          Ruby and the gemset:

    ```zsh
    $ cd ..
    $ cd spotlight
    ```

13. Installed the gems (for local development):

    ```zsh
    $ bundle config without production
    $ bundle install
    ```

14. Switched out of the directory and back in (not sure why this step is
    necessary):

    ```zsh
    $ cd ..
    $ cd spotlight
    ```

15. Ran the database migrations, and committed the resulting changes to the
    “db/schema.rb” file:

    ```zsh
    $ SKIP_TRANSLATION=1 rails db:migrate

    $ git add db/schema.rb
    $ git commit
    ```

16. Added a “LICENSE.md” file containing the Apache License v2.0, in accordance
    with SSDR policy (copied the actual file from the
    <https://github.com/umd-lib/reciprocal-borrowing> repository).

----

[spotlight-plugin]: https://github.com/projectblacklight/spotlight
