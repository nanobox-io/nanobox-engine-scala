# Scala

This is a Scala engine used to launch Scala apps on [Nanobox](http://nanobox.io).

## Usage
To use the Scala engine, specify `scala` as your `engine` in your boxfile.yml.

```yaml
run.config:
  engine: scala
```

## Build Process
When preparing your application for deploy, this engine compiles code by doing the following:

- `sbt compile stage`

*Heads Up:* This engine assumes you have [sbt-native-packager](https://github.com/sbt/sbt-native-packager/blob/master/README.md) configured. 

## Basic Configuration Options

This engine exposes configuration options through the [boxfile.yml](http://docs.nanobox.io/app-config/boxfile/), a yaml config file used to provision and configure your app's infrastructure when using Nanobox.


#### Overview of Basic Boxfile Configuration Options
```yaml
run.config:
  engine.config:
    # Java Settings
    java_runtime: sun-jdk8
```

### Java Settings
The following setting allows you to define your Java runtime environment.

---

#### java_runtime
Specifies which Java runtime and version to use. The following runtimes are available:

- openjdk8
- sun-jdk6
- sun-jdk7
- oracle-jdk8

```yaml
run.config:
  engine.config:
    java_runtime: oracle-jdk8
```

---

## Help & Support
This is a Scala engine provided by [Nanobox](http://nanobox.io). If you need help with this engine, you can reach out to us in the [Nanobox Slack channel](https://nanoboxio.slack.com) (access can be requested at [slack.nanoapp.io](http://slack.nanoapp.io)). If you are running into an issue with the engine, feel free to [create a new issue on this project](https://github.com/nanobox-io/nanobox-engine-scala/issues/new).
