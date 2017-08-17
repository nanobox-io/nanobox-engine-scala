# Scala

This is a Scala engine used to launch Scala apps on [Nanobox](http://nanobox.io).

## Usage
To use the Scala engine, specify `scala` as your `engine` in your boxfile.yml.

```yaml
run.config:
  engine: scala
```

## Build Process
When [running a build](https://docs.nanboox.io/cli/build/), this engine compiles code by doing the following:

- `sbt`


## Basic Configuration Options

This engine exposes configuration options through the [boxfile.yml](http://docs.nanobox.io/app-config/boxfile/), a yaml config file used to provision and configure your app's infrastructure when using Nanobox.


#### Overview of Basic Boxfile Configuration Options
```yaml
run.config:
  engine.config:
    # Java Settings
    java_runtime: sun-jdk8

    # sbt Settings
    sbt_compile: 'clean assembly'
```

##### Quick links
[Java Settings](#java-settings)  
[sbt Settings](#sbt-settings)  
[Node.js Settings](#nodejs-settings)

---

### Java Settings
The following setting allows you to define your Java runtime environment.

---

#### java_runtime
Specifies which Java runtime and version to use. The following runtimes are available:

- openjdk7
- openjdk8
- sun-jdk6
- sun-jdk7
- sun-jdk8
- oracle-jdk8 *(default)*

```yaml
run.config:
  engine.config:
    java_runtime: oracle-jdk8
```

---

### sbt Settings
The following setting allows you to define sbt-specific options.

---

#### sbt_compile
Defines what arguments to pass when running sbt.

```yaml
run.config:
  engine.config:
    sbt_compile: 'clean assembly'
```

---


## Help & Support
This is a Scala engine provided by [Nanobox](http://nanobox.io). If you need help with this engine, you can reach out to us in the [#nanobox IRC channel](http://webchat.freenode.net/?channels=nanobox). If you are running into an issue with the engine, feel free to [create a new issue on this project](https://github.com/nanobox-io/nanobox-engine-scala/issues/new).
