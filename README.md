# Freshli Agent: Java

This application is used by the [`freshli` CLI](https://github.com/corgibytes/freshli-cli) to detect and process manifest files from the Java ecosystem. It runs on Java 8 or newer, and is tested against Java 8, 11, and 17 on both Windows and Linux.

## Building

### With Docker

Make sure you have a recent version of [Docker](https://docker.com) installed, and then run the following.

```bash
docker build -t freshli-agent-java . 
```

### Without Docker

#### Using `bin/build.rb`

Assuming you have a recent version of Ruby installed, and you're able to install RubyGems with being logged in as root, then you can use the `bin/build.rb` script to build the application.

> :warning: **Note for Windows Users**
> Ruby version 3.1 might not work, because of compatibility issues with one of the libraries that is used by the Cucumber/Aruba testing tool. All Ruby 3.0 versions are suspected to work. Testing has been done with the version of ruby that can be installed via `winget install RubyInstallerTeam.RubyWithDevKit.3.0`. Please create an issue if you see errors when running the build or the tests using the scripts in the `bin` directory or when running `bundle exec cucumber`.

On macOS or Linux:
```bash
bin/build.rb
```

On Windows:
```pwsh
ruby .\bin\build.rb
```

#### Using Gradle

Make sure you have JDK version 17 or later installed and have your `JAVA_HOME` environment varibale set appropriately.

Run the following command to create a complete deployable distribution for the project.

On macOS or Linux:
```bash
./gradlew installDist
```

On Windows:
```pwsh
.\gradlew.bat installDist
```

This will create `build/install/freshli-agent-java`. Within that folder, the `bin` directory contains wrappers for running the application. Adding the full path to that `bin` directory to the `PATH` environment variable will enable you to run `freshli-agent-java` from any directory.

## Running

### With Docker

Assuming the Docker container has been built following the instructions above, the following command will run the application

```bash
docker run freshli-agent-java --help
```

### Without Docker

#### Running with Gradle

It's possible to instruct Gradle to run the command for you.

On macOS and Linux:
```bash
./gradle run --args="--help"
```

On Windows:
```pwsh
`.\gradlew.bat run --args="--help"
```

#### Running from Distribution Directory

You can run the program from the distribution that's created by the `installDist` Gradle task.

On macOS and Linux:
```bash
./build/install/freshli-agent-java/bin/freshli-agent-java.bat --help
```

On Windows:
```pwsh
.\build\install\freshli-agent-java\bin\freshli-agent-java --help
```

### Running Tests

#### Dependencies

The [`cyclonedx` CLI](https://github.com/CycloneDX/cyclonedx-cli) command needs to be in your `PATH` for the tests to pass. You'll need to [download](https://github.com/CycloneDX/cyclonedx-cli/releases) the version of the command that matches your platform, and rename it to `cyclonedx` before placing its directory in the `PATH` environment variable. 

#### Using `bin/test.rb`

You can run both the application's unit and integration tests that are written in Kotlin and the application's acceptance tests that are written using Cucumber and Aruba by running:

On macOS and Linux:
```bash
bin/test.rb
```

On Windows:
```pwsh
ruby .\bin\test.rb
```

#### Running Directly

The application's unit tests can be run with:

On macOS and Linux:
```bash
./gradlew test
```

On Windows:
```pwsh
.\gradlew.bat test
```

And the application's acceptance tests can be run with:

```bash
bundle exec cucumber
```
