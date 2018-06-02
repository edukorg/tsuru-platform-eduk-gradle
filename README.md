# Gradle-SDKMAN tsuru custom platform

This repository defines a [tsuru platform](https://github.com/tsuru/platforms/) to run [Gradle](https://github.com/tsuru/platforms/) projects using [SDKMAN](https://sdkman.io) runtimes.

## Usage
### Configure the project
To use this platform a file named `sdk.conf` must be avaiable on the project's root dir. It should have the runtimes to be installed by SDKMAN listed, one by line with optional version on the same line splited by a space character. Like the example:
```
java 8.0.172-zulu
scala
kotlin 1.2.41
```
A list with the available SDK's can be found in [SDKMAN website](https://sdkman.io/sdks).

In the deploy phase the SDKMAN will be used to install the listed platforms. The Gradle can be listed to specify a specific version. If not listed a default version (`4.7`) will be installed.

The gradle will be avaiable to run the project. The `Procfile` can be define with something like this:
```
web: gradle run --console plain --no-daemon
```

The `--console plain` and `--no-daemon` are recommended to avoid problems logging the application output.

If you have a Gradle Wrapper in your project you can use it in the Procfile to run the application.

For the `gradle run` (or `gradlew run`, if using the wrapper) to work the `application` plugin must be used (e.g. in the `build.gradle` file) and the `mainClassName` must be defined, as the example:
```
apply plugin: 'application'

mainClassName = 'com.eduk.helloworld.MainKt'
```

A `tsuru.yml` can be used to run extra build build tasks and to define the `healthcheck`:
```
healthcheck:
  path: /healthcheck
  method: GET
  status: 200
  allowed_failures: 3
```

See [Tsuru docs](https://docs.tsuru.io/stable/using/tsuru.yaml.html) for more info.

### Add the platform on Tsuru
If the platform is not already instaled, add it to tsuru by running:
```
tsuru platform-add gradle-sdkman -d https://github.com/edukorg/tsuru-platform-eduk-gradle/raw/master/Dockerfile
```

You can use the name `gradle-sdkman` or any other you like.

The platform image's extra files are defined in the `Dockerfile` with the Github RAW link to the master branch. This is needed so the tsuru's node responsible for the platform's image creation will be able to retreive the necessary files.

### Create the application
The application can be created the same way it's created for any other platform:
```
tsuru app-create hello-kotlin gradle-sdkman -p a_plan -t a_team -o a_pool -d "Some nice description"
```

### Deploy code
You can deploy your code normally by git pushing it to [Gandalf](https://github.com/tsuru/gandalf) or by using `tsuru app-deploy`.

## Other recommendations
- Try to control the app memory consuption by using `GRADLE_OPTS="-Xms256m -Xmx512m" or alternatives. By default the JVM will think all the node memory is avaiable to satisfy it desires and it can have problems when Docker deny more memory than it can have.
- The Gradle dependecies are downloaded as jar files and can have significant sizes leading to huge application images which can make the deploy, start, restart and scale-up actions slow. Try to avoid this by keeping control on the project's dependencies.

## Limitations
- The `ENV` var must not be defined in the project or with `tsuru env-set`. It is used in the platform to make `bash` source the `SDKMAN` init script and make the SDKs avaiable. As `bash` is invoked as `sh` it uses a POSIX compatible non-iterative mode and it only consider the files defined in the `ENV` var to run some initialization step, as described in the [bash manual](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html).
- For now the wrapped `gradlew` script can be used only to run the application. It's ignored in the deploy phase and a local Gradle is installed anyway.

