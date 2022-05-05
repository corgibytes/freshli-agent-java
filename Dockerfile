FROM eclipse-temurin:17 as build

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

RUN mkdir -p /opt/src/app
WORKDIR /opt/src/app

COPY . /opt/src/app

RUN ./gradlew installDist


FROM debian:buster-slim as deploy

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=build /javaruntime $JAVA_HOME
COPY --from=build /opt/src/app/build/install /opt/

COPY ./docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh