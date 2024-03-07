# Dockerfile for the generating the Rails application Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/spotlight:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.

ARG RUBY_VERSION=3.0.6
FROM ruby:$RUBY_VERSION-slim-bullseye

RUN apt update && \
    apt install -y \
    build-essential \
    curl \
    git \
    imagemagick \
    libpq-dev \
    shared-mime-info \
    tzdata \
    zip \
    && apt-get clean

# Install Node.js from https://github.com/nodesource/
# (see https://github.com/nodesource/distributions), because Node version
# available from Debian package archive is too old (Node v12).
# Have to use Node 16, as otherwise assets won't compile
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Install Yarn
RUN npm install --global yarn@1.22.19

ARG UID=9999
ARG GID=9999
ARG USER=spotlight
ARG GROUP=spotlight
ARG APP_DIR=/spotlight

RUN addgroup --gid $GID --system $USER && \
  adduser --uid $UID --system \
  --ingroup $GROUP --home $APP_DIR $USER

USER spotlight
WORKDIR $APP_DIR

ARG BUNDLER_VERSION=2.5.6

COPY --chown=$UID:$GID Gemfile Gemfile.lock $APP_DIR

RUN cd $APP_DIR && \
    gem install bundler --version $BUNDLER_VERSION && \
    bundle config without development test && \
    bundle install --jobs 20 --retry 5

# Copy the main application.
COPY --chown=$UID:$GID . $APP_DIR

# Copy Rails application start scripts
COPY --chown=app:app docker_config/spotlight/* $APP_DIR

# RAILS_RELATIVE_URL_ROOT and SCRIPT_NAME are only needed if application is
# running on a URL subpath
# ENV RAILS_RELATIVE_URL_ROOT=/subpath
# ENV SCRIPT_NAME=/subpath

# The following SECRET_KEY_BASE variable is used so that the
# "assets:precompile" command will run run without throwing an error.
# It will have no effect on the application when it is actually run.
#
# Similarly, the PROD_DATABASE_ADAPTER variable is needed for the
# "assets:precompile" Rake task to complete, but will have no effect
# on the application when it is actually run.

# Needed because of a "error:0308010C:digital envelope routines::unsupported"
# error message when pre-compiling assets
#(see https://stackoverflow.com/a/69699772)
ENV NODE_OPTIONS=--openssl-legacy-provider

ENV SKIP_TRANSLATION=1
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=IGNORE_ME
RUN bin/yarn add @babel/plugin-proposal-private-property-in-object
RUN cd $APP_DIR && \
    PROD_DATABASE_ADAPTER=postgresql bundle exec rails assets:precompile

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts.
CMD ["/spotlight/rails_start.sh"]
