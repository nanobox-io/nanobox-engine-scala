#!/bin/bash

# Here we get to be a bit clever. sbt will store it's cache (deps, etc)
# in the HOME dir. Changing this is not easily configurable, so we'll
# essentially setup a cache dir in ~/.nanobox/sbt_cache, and symlink
# the ~/.{ivy2,sbt} to the cached location.

# remove ~/.sbt if it's a directory
if [[ -d ~/.sbt ]]; then
  rm -rf ~/.sbt
fi

# remove ~/.ivy2 if it's a directory
if [[ -d ~/.ivy2 ]]; then
  rm -rf ~/.ivy2
fi

# if ~/.sbt isn't a symlink, create it
if [[ ! -s ~/.sbt ]]; then
  mkdir -p {{code_dir}}/.nanobox/sbt_cache/sbt
  ln -s {{code_dir}}/.nanobox/sbt_cache/sbt ~/.sbt
fi

# if ~/.ivy2 isn't a symlink, create it
if [[ ! -s ~/.ivy2 ]]; then
  mkdir -p {{code_dir}}/.nanobox/sbt_cache/ivy2
  ln -s {{code_dir}}/.nanobox/sbt_cache/ivy2 ~/.ivy2
fi
