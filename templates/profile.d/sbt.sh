#!/bin/bash

# create a symlink to cache dirs

if [[ -d ~/.sbt ]]; then
  rm -rf ~/.sbt
fi

if [[ -d ~/.ivy2 ]]; then
  rm -rf ~/.ivy2
fi

if [[ ! -s ~/.sbt ]]; then
  mkdir -p {{code_dir}}/.nanobox/sbt_cache/sbt
  ln -s {{code_dir}}/.nanobox/sbt_cache/sbt ~/.sbt
fi

if [[ ! -s ~/.ivy2 ]]; then
  mkdir -p {{code_dir}}/.nanobox/sbt_cache/ivy2
  ln -s {{code_dir}}/.nanobox/sbt_cache/ivy2 ~/.ivy2
fi
