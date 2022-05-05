# Freshli Agent: Java

This application is used by the [`freshli` CLI](https://github.com/corgibytes/freshli-cli) to detect and process manifest files from the Java ecosystem.

## Building

### With Docker

Make sure you have a recent version of [Docker](https://docker.com) installed, and then run the following.

```bash
docker build -t freshli-agent-java . 
```

### Without Docker

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
