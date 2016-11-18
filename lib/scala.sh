# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

java_runtime() {
  echo $(nos_validate "$(nos_payload 'config_java_runtime')" "string" "oracle-jdk8")
}

install_runtime() {
  pkgs=($(java_runtime) $(scala_runtime) $(sbt_runtime))

  nos_install ${pkgs[@]}
}

# Uninstall build dependencies
uninstall_build_packages() {
  # currently ruby doesn't install any build-only deps... I think
  pkgs=()

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
