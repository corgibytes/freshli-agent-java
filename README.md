# Freshli Agent: Java

This application is used by the [`freshli` CLI](https://github.com/corgibytes/freshli-cli) to detect and process manifest files from the Java ecosystem.

## Building

### With Docker

Make sure you have a recent version of [Docker](https://docker.com) installed, and then run the following.

```bash
docker build -t freshli-agent-java . 
```

### Without Docker

#### Using `bin/build.rb`

Assuming you have a recent version of Ruby installed, and you're able to install RubyGems with being logged in as root, then you can use the `bin/build.rb` script to build the application.

```bash
bin/build.rb
```

#### Using Gradle

Make sure you have JDK version 17 or later installed and have your `JAVA_HOME` environment varibale set appropriately.

Run the following command to create a complete deployable distribution for the project.

```bash
./gradle installDist
```

This will create `build/install/freshli-agent-java`. Inside the `bin` directory contain within are wrappers for running the application.

## Running

### With Docker

Assuming the Docker container has been built following the instructions above, the following command will run the application

```bash
docker run freshli-agent-java --help
```

### Without Docker

#### Running with Gradle

It's possible to instruct Gradle to run the command for you.

```bash
./gradle run --args="--help"
```

#### Running from Distribution Directory

You can run the program from the distribution that's created by the `installDist` Gradle task.

```bash
./build/install/freshli-agent-java/bin/freshli-agent-java --help
```

#### Using symbolic link in `exe` directory

`./gradlew installDist` (which is also run by `bin/build.rb`) creates a symbolic link in the `exe` directory to assist with running the application. The symbolic link points to the directory in the distribution directory as described above.

```bash
exe/freshli-agent-java --help
```

### Running Tests

#### Using `bin/test.rb`

You can run both the application's unit tests that are written in Kotlin and the application's acceptance tests that are written using Cucumber and Aruba by running:

```bash
bin/test.rb
```

#### Running Directly

The application's unit tests can be run with:

```bash
./gradlew test
```

And the application's acceptance tests can be run with:

```bash
bundle exec cucumber
```
