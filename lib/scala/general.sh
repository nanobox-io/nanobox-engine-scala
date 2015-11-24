# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

scala_create_boxfile() {
  nos_template \
    "boxfile.mustache" \
    "-" \
    "$(scala_boxfile_payload)"
}

scala_boxfile_payload() {
  cat <<-END
{
  "has_bower": $(nodejs_has_bower),
  "java_home": "$(java_home)",
  "live_dir": "$(nos_live_dir)",
  "etc_dir": "$(nos_etc_dir)",
  "deploy_dir": "$(nos_deploy_dir)"
}
END
}

scala_create_profile_links() {
  mkdir -p $(nos_etc_dir)/profile.d/
  nos_template \
    "links.sh.mustache" \
    "$(etc_dir)/profile.d/links.sh" \
    "$(scala_links_payload)"
}

scala_links_payload() {
  cat <<-END
{
  "live_dir": "$(nos_live_dir)"
}
END
}

scala_runtime() {
  echo "$(java_condensed_runtime)-scala"
}

scala_install_runtime() {
  nos_install "$(scala_runtime)"
}

scala_sbt_runtime() {
  echo "$(java_condensed_runtime)-sbt"
}

scala_install_sbt() {
  nos_install "$(scala_sbt_runtime)"
}

scala_sbt_cache_dir() {
  [[ ! -f $(nos_code_dir)/.sbt ]] && nos_run_subprocess "make sbt cache dir" "mkdir -p $(nos_code_dir)/.sbt"
  [[ ! -s ${HOME}/.sbt ]] && nos_run_subprocess "link sbt cache dir" "ln -s $(nos_code_dir)/.sbt ${HOME}/.sbt"
  [[ ! -f $(nos_code_dir)/.ivy2 ]] && nos_run_subprocess "make ivy2 cache dir" "mkdir -p $(nos_code_dir)/.ivy2"
  [[ ! -s ${HOME}/.ivy2 ]] && nos_run_subprocess "link ivy2 cache dir" "ln -s $(nos_code_dir)/.ivy2 ${HOME}/.ivy2"
}

scala_sbt_compile() {
  (cd $(nos_code_dir); nos_run_subprocess "sbt compile" "sbt compile stage")
}

scala_create_pid_file() {
  mkdir -p  $(nos_deploy_dir)/var/run
  touch $(nos_deploy_dir)/var/run/RUNNING_PID
  [[ ! -s $(nos_code_dir)/target/universal/stage/RUNNING_PID ]] && ln -s $(nos_deploy_dir)/var/run/RUNNING_PID $(nos_code_dir)/target/universal/stage/RUNNING_PID
}
