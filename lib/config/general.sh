# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

create_boxfile() {
  template \
    "boxfile.mustache" \
    "-" \
    "$(boxfile_payload)"
}

boxfile_payload() {
    cat <<-END
{
  "has_bower": $(has_bower),
  "java_home": "$(java_home)",
  "live_dir": "$(live_dir)",
  "etc_dir": "$(etc_dir)",
  "deploy_dir": "$(deploy_dir)"
}
END
}

create_profile_links() {
  mkdir -p $(etc_dir)/profile.d/
  template \
    "links.sh.mustache" \
    "$(etc_dir)/profile.d/links.sh" \
    "$(links_payload)"
}

links_payload() {
  cat <<-END
{
  "live_dir": "$(live_dir)"
}
END
}

app_name() {
  # payload app
  echo "$(payload app)"
}

live_dir() {
  # payload live_dir
  echo $(payload "live_dir")
}

deploy_dir() {
  # payload deploy_dir
  echo $(payload "deploy_dir")
}

etc_dir() {
  echo $(payload "etc_dir")
}

code_dir() {
  echo $(payload "code_dir")
}

runtime() {
  echo $(validate "$(payload 'boxfile_runtime')" "string" "openjdk8")
}

install_runtime() {
  install "$(runtime)"
}

condensed_runtime() {
  java_runtime="$(runtime)"
  echo ${java_runtime//[.-]/}
}

java_home() {
  case "$(runtime)" in
  sun-j??8)
    echo "$(deploy_dir)/java/sun-8"
    ;;
  sun-j??7)
    echo "$(deploy_dir)/java/sun-7"
    ;;
  sun-j??6)
    echo "$(deploy_dir)/java/sun-6"
    ;;
  openjdk8)
    echo "$(deploy_dir)/java/openjdk8"
    ;;
  openjdk7)
    echo "$(deploy_dir)/java/openjdk7"
    ;;
  esac
}

sbt_runtime() {
  echo "$(condensed_runtime)-sbt"
}

install_sbt() {
  install "$(sbt_runtime)"
}

sbt_cache_dir() {
  [[ ! -f $(code_dir)/.sbt ]] && run_subprocess "make sbt cache dir" "mkdir -p $(code_dir)/.sbt"
  [[ ! -s ${HOME}/.sbt ]] && run_subprocess "link sbt cache dir" "ln -s $(code_dir)/.sbt ${HOME}/.sbt"
  [[ ! -f $(code_dir)/.ivy2 ]] && run_subprocess "make ivy2 cache dir" "mkdir -p $(code_dir)/.ivy2"
  [[ ! -s ${HOME}/.ivy2 ]] && run_subprocess "link ivy2 cache dir" "ln -s $(code_dir)/.ivy2 ${HOME}/.ivy2"
}

sbt_compile() {
  (cd $(code_dir); run_subprocess "sbt compile" "sbt compile stage")
}

create_pid_file() {
  mkdir -p  $(deploy_dir)/var/run
  touch $(deploy_dir)/var/run/RUNNING_PID
  [[ ! -s $(code_dir)/target/universal/stage/RUNNING_PID ]] && ln -s $(deploy_dir)/var/run/RUNNING_PID $(code_dir)/target/universal/stage/RUNNING_PID
}

js_runtime() {
  echo $(validate "$(payload "boxfile_js_runtime")" "string" "nodejs-0.12")
}

install_js_runtime() {
  install "$(js_runtime)"
}

set_js_runtime() {
  [[ -d $(code_dir)/node_modules ]] && echo "$(js_runtime)" > $(code_dir)/node_modules/runtime
}

create_database_url() {
  if [[ -n "$(payload 'env_POSTGRESQL1_HOST')" ]]; then
    persist_evar "DATABASE_URL" "postgres://$(payload 'env_POSTGRESQL1_USER'):$(payload 'env_POSTGRESQL1_PASS')@$(payload 'env_POSTGRESQL1_HOST'):$(payload 'env_POSTGRESQL1_PORT')/$(payload 'env_POSTGRESQL1_NAME')"
  fi
}