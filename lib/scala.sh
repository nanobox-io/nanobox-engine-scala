# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

java_runtime() {
  echo $(nos_validate "$(nos_payload 'config_java_runtime')" "string" "oracle-jdk8")
}

# install Java, Scala, and sbt (Scala Build Tool)
install_runtime() {
  pkgs=($(java_runtime) $(scala_runtime) $(sbt_runtime))

  nos_install ${pkgs[@]}
}

# Uninstall build dependencies
uninstall_build_packages() {
  # when using sbt-native, we can uninstall everything except the JRE
  pkgs=($(scala_runtime) $(sbt_runtime))

  # if pkgs isn't empty, let's uninstall what we don't need
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    nos_uninstall ${pkgs[@]}
  fi
}

# Convert jdk-8 into jdk8, etc
condensed_java_runtime() {
  java_runtime="$(java_runtime)"
  echo ${java_runtime//[.-]/}
}

# java is complicated, and consequently the home directory of the java
# installation depends wholly on which flavor of java is installed
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

# We need to inform the java runtime where it's HOME is, give it
# some special opts, and also set the PORT for the app to use
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

# Here we get to be a bit clever. sbt will store it's cache (deps, etc)
# in the HOME dir. Changing this is not easily configurable, so we'll
# essentially setup a cache dir in ~/.nanobox/sbt_cache, and symlink
# the ~/.{ivy2,sbt} to the cached location. Also, we'll copy anything
# into the cache on the first run.
setup_scala_env() {
  
  # Ensure the cache destination exists for sbt & ivy2
  if [[ ! -d "$(nos_code_dir)/.nanobox/sbt_cache/sbt" ]]; then
    mkdir -p "$(nos_code_dir)/.nanobox/sbt_cache/sbt"
  fi
  if [[ ! -d "$(nos_code_dir)/.nanobox/sbt_cache/ivy2" ]]; then
    mkdir -p "$(nos_code_dir)/.nanobox/sbt_cache/ivy2"
  fi
  
  # If anything exists before we symlink, copy it into the cache
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

# jdk8-sbt, etc
sbt_runtime() {
  echo "$(condensed_java_runtime)-sbt"
}

# jdk8-scala, etc
scala_runtime() {
	echo "$(condensed_java_runtime)-scala"
}

# https://github.com/sbt/sbt-native-packager/blob/master/README.md
sbt_release_target() {
  echo $(nos_validate "$(nos_payload 'config_sbt_release_target')" "string" "compile stage")
}

# The sbt command to compile and generate a release. By default will be sbt compile stage
sbt_compile() {
  (cd $(nos_code_dir); nos_run_process "sbt compile" "sbt $(sbt_release_target)")
}

# Extract the extra_package_dirs from the engine.config, and echo the list
extra_package_dirs() {
  declare -a extra_package_dirs_list
  if [[ "${PL_config_extra_package_dirs_type}" = "array" ]]; then
    for ((i=0; i < PL_config_extra_package_dirs_length ; i++)); do
      type=PL_config_extra_package_dirs_${i}_type
      value=PL_config_extra_package_dirs_${i}_value
      if [[ ${!type} = "string" ]]; then
        if [[ -d $(nos_code_dir)/${!value} ]]; then
          add="true"
          for j in "${extra_package_dirs_list[@]}"; do
            if [[ "$j" = "${!value}" ]]; then
              add="false"
              break;
            fi
          done
          if [[ "$add" = "true" ]]; then
            extra_package_dirs_list+=(${!value})
          fi
        fi
      fi
    done
  fi
  if [[ -z "extra_package_dirs_list[@]" ]]; then
    echo ""
  else
    echo "${extra_package_dirs_list[@]}"
  fi
}

# First copy the compiled stage into the deployed app directory
# then, copy any extra package dirs specified in the engine.config
publish_release() {
  nos_print_bullet "Moving code into app directory..."
  rsync -a $(nos_code_dir)/target/universal/stage/ $(nos_app_dir)

  for i in $(extra_package_dirs); do
    rsync -a $(nos_code_dir)/${i} $(nos_app_dir)
  done
}
