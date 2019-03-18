#!/bin/bash

# This file runs tests for merges, PRs, and nightlies.
# There are a few rules for what tests are run:
#  * PRs run all non-acceptance tests for every library.
#  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries.
#  * Nightlies run all acceptance tests for every library.
#  * Currently only runs tests on 2.5.0

set -eo pipefail

# Debug: show build environment
env | grep KOKORO

cd github/google-cloud-ruby/

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
    EXIT_STATUS=1
}

versions=(2.3.8 2.4.5 2.5.5 2.6.2)

source /Users/kbuilder/.rvm/scripts/rvm

if [ "$JOB_TYPE" = "presubmit" ]; then
    (rvm use ${versions[2]}@global --default) || (rvm install ${versions[2]}@global && rvm use ${versions[2]}@global --default)
    echo $PATH
    which bundler
    which ruby
    gem install bundler --version 1.17.3
    echo $PATH
    which bundler
    which ruby
    gem update --system
    echo $PATH
    which bundler
    which ruby
    gem pristine --binstubs
    echo $PATH
    which bundler
    which ruby
    ruby --version
    echo $PATH
    which bundler
    (bundle update && bundle exec rake kokoro:presubmit) || set_failed_status
else
    for version in "${versions[@]}"; do
        (rvm use "$version"@global --default) || (rvm install "$version" && rvm use "$version"@global --default)
        git fetch --depth=10000
        gem install bundler --version 1.17.3
        gem update --system
        gem regenerate_binstubs
        ruby --version
        which bundle
        (bundle update && bundle exec rake kokoro:"$JOB_TYPE") || set_failed_status
    done
fi

exit $EXIT_STATUS
