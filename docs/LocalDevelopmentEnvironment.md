# Local Development Environment

## Introduction

This page contains information on running the "spotlight" Rails application
in a local development environment.

## Prerequisites

The following procedure assumes the following are installed on the local
workstation:

* RVM
* Ruby 3.0.6
* Node v18
* Yarn 1.22.x
* ImageMagick
  * On MacOS, can be installed via `brew imagemagik`

## Running the application

1. In an empty directory, clone the Git repository and switch into the
   directory:

    ```zsh
    $ git clone git@github.com:umd-lib/spotlight.git
    $ cd spotlight
    ```

2. Checkout the appropriate Git tag, branch, or commit for the Docker image.

3. Switch out of the application and back in to enable RVM to configure the
   Ruby and gemset:

    ```zsh
    $ cd ..
    $ cd spotlight
    ```

4. Install the "bundler" gem:

    ```zsh
    $ gem install bundler --version 2.5.6
    ```

5. Install the application gems:

    ```zsh
    $ bundle config without production
    $ bundle install
    ```

6. Install the Node packages:

    ```zsh
    $ yarn
    ```

7. Run the database migration:

    ```zsh
    $ SKIP_TRANSLATION=1 rails db:migrate
    ```

8. Run the application:

    ```zsh
    $ rails server
    ```

9. In a new terminal, switch into the project directory, and run a Solr Docker
   image:

    ```zsh
    $ docker run --rm -p 8983:8983 --name spotlight_solr \
                 -v $PWD/solr:/opt/solr/server/solr/configsets/blacklight-core \
                 solr:9.5.0 solr-precreate blacklight-core /opt/solr/server/solr/configsets/blacklight-core
    ```

10. In a new terminal, switch into the project directory, and run a Redis Docker
    image:

    ```zsh
    $ docker run --rm --publish 6379:6379 redis:7.2.4
    ```

11. In a new terminal, switch into the project directory, and run Sidekiq:

    ```zsh
    $ sidekiq
    ```

12. In a web browser, go to

    <http://localhost:3000/>

    The Spotlight home page will be displayed.

13. The first user to log in is the administrator. To add a user, go
    to

    <http://localhost:3000/users/sign_up>

    and fill out the form.

