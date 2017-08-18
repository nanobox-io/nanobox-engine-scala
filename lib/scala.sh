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

setup_java_env() {
  if [[ ! -f "$(nos_etc_dir)/env.d/JAVA_HOME" ]]; then
    echo "$(java_home)" > "$(nos_etc_dir)/env.d/JAVA_HOME"
  fi
  if [[ ! -f "$(nos_etc_dir)/env.d/JAVA_OPTS" ]]; then
    echo "-XX:+UseCompressedOops" > "$(nos_etc_dir)/env.d/JAVA_OPTS"
  fi
  if [[ ! -f "$(nos_etc_dir)/env.d/PORT" ]]; then
    echo "8080" > "$(nos_etc_dir)/env.d/PORT"
  fi
}

setup_scala_env() {
  if [[ ! -d "$(nos_code_dir)/.nanobox/sbt_cache/sbt" ]]; then
    mkdir -p "$(nos_code_dir)/.nanobox/sbt_cache/sbt"
  fi
  if [[ ! -d "$(nos_code_dir)/.nanobox/sbt_cache/ivy2" ]]; then
    mkdir -p "$(nos_code_dir)/.nanobox/sbt_cache/ivy2"
  fi
  if [[ -d ~/.sbt ]]; then
    mv ~/.sbt/* "$(nos_code_dir)/.nanobox/sbt_cache/sbt"
  fi
  if [[ -d ~/.ivy2 ]]; then
    mv ~/.ivy2/* "$(nos_code_dir)/.nanobox/sbt_cache/ivy2"
  fi
}

# Generate the payload to render the scala profile template
scala_profile_payload() {
  cat <<-END
{
  "code_dir": "$(nos_code_dir)"
}
END
}

# Profile script to ensure symlinks for sbt and ivy2
scala_profile_script() {
  mkdir -p "$(nos_etc_dir)/profile.d"
  nos_template \
    "profile.d/sbt.sh" \
    "$(nos_etc_dir)/profile.d/sbt.sh" \
    "$(scala_profile_payload)"
}

sbt_runtime() {
  echo "$(condensed_java_runtime)-sbt"
}

scala_runtime() {
	echo "$(condensed_java_runtime)-scala"
}

sbt_release_target() {
  echo $(nos_validate "$(nos_payload 'config_sbt_release_target')" "string" "dist")
}

sbt_compile() {
  (cd $(nos_code_dir); nos_run_process "sbt compile" "sbt $(sbt_release_target)")
}

publish_release() {
  nos_print_bullet "Moving code into app directory..."
  rsync -a $(nos_code_dir)/ $(nos_app_dir)
}
