#!/bin/bash --login

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

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
    EXIT_STATUS=1
}

echo "script started"
echo $PATH
rvm get head --auto-dotfiles
echo "ran rvm auto-dotfiles"

versions=(2.3.8 2.4.5 2.5.5 2.6.2)
echo "set versions"

if [ "$JOB_TYPE" = "presubmit" ]; then
    echo "recognized presubmit"
    {
      rvm use ${versions[2]}@global --default
      echo "tried to use 2"
    } || {
      rvm install ${versions[2]}
      echo "installed 2"
      rvm use ${versions[2]}@global --default
      echo "using 2"
      echo $PATH
      which bundler
      which ruby
      gem uninstall --force --silent bundler
      echo "nuked bundler"
    }
    gem install bundler --version 1.17.3
    echo "installed bundler"
    echo $PATH
    which bundler
    which ruby
    gem update --system
    echo "updated system"
    echo $PATH
    which bundler
    which ruby
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
