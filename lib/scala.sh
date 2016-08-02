# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# source nodejs
. ${engine_lib_dir}/nodejs.sh

create_profile_links() {
  mkdir -p $(nos_data_dir)/etc/profile.d/
  nos_template \
    "links.sh.mustache" \
    "$(nos_data_dir)/etc/profile.d/links.sh" \
    "$(links_payload)"
}

links_payload() {
  cat <<-END
{
  "nos_app_dir": "${nos_app_dir}"
}
END
}

java_runtime() {
  echo $(nos_validate "$(nos_payload 'config_java_runtime')" "string" "oracle-jdk8")
}

install_runtime() {
  pkgs=($(java_runtime) $(scala_runtime) $(sbt_runtime))

  if [[ "$(is_nodejs_required)" = "true" ]]; then
    pkgs+=("$(nodejs_dependencies)")
  fi

  nos_install ${pkgs[@]}
}

# Uninstall build dependencies
uninstall_build_packages() {
  # currently ruby doesn't install any build-only deps... I think
  pkgs=()

  # if nodejs is required, let's fetch any node build deps
  if [[ "$(is_nodejs_required)" = "true" ]]; then
    pkgs+=("$(nodejs_build_dependencies)")
  fi

  # if pkgs isn't empty, let's uninstall what we don't need
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    nos_uninstall ${pkgs[@]}
  fi
}

condensed_java_runtime() {
  java_runtime="$(java_runtime)"
  echo ${java_runtime//[.-]/}
}

java_home() {
  case "$(java_runtime)" in
  oracle-j??8)
    echo "$(nos_data_dir)/java/oracle-8"
    ;;
  sun-j??7)
    echo "$(nos_data_dir)/java/sun-7"
    ;;
  sun-j??6)
    echo "$(nos_data_dir)/java/sun-6"
    ;;
  openjdk8)
    echo "$(nos_data_dir)/java/openjdk8"
    ;;
  openjdk7)
    echo "$(nos_data_dir)/java/openjdk7"
    ;;
  esac
}

sbt_runtime() {
  echo "$(condensed_java_runtime)-sbt"
}

scala_runtime() {
	echo "$(condensed_java_runtime)-scala"
}

sbt_cache_dir() {
  [[ ! -f $(nos_code_dir)/.sbt ]] && nos_run_process "make sbt cache dir" "mkdir -p $(nos_code_dir)/.sbt"
  [[ ! -s ${HOME}/.sbt ]] && nos_run_process "link sbt cache dir" "ln -s $(nos_code_dir)/.sbt ${HOME}/.sbt"
  [[ ! -f $(nos_code_dir)/.ivy2 ]] && nos_run_process "make ivy2 cache dir" "mkdir -p $(nos_code_dir)/.ivy2"
  [[ ! -s ${HOME}/.ivy2 ]] && nos_run_process "link ivy2 cache dir" "ln -s $(nos_code_dir)/.ivy2 ${HOME}/.ivy2"
}

sbt_compile_args() {
  echo $(nos_validate "$(nos_payload 'config_sbt_compile')" "string" "clean assembly")
}

sbt_compile() {
  (cd $(nos_code_dir); nos_run_process "sbt compile" "sbt $(sbt_compile_args)")
}

publish_release() {
  nos_print_bullet "Moving code into app directory..."
  rsync -a $(nos_code_dir)/ $(nos_app_dir)
}