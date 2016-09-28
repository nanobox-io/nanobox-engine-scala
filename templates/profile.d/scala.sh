# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

if [ ! -s ${HOME}/.ivy2 ]; then
  ln -sf {{data_dir}}/var/ivy2 ${HOME}/.ivy2
fi

if [ ! -s ${HOME}/.sbt ]; then
  ln -sf {{data_dir}}/var/sbt ${HOME}/.sbt
fi