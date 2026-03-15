FROM maven:3.9.9-eclipse-temurin-8 AS build

WORKDIR /build

COPY pom.xml /build/pom.xml
COPY src /build/src
COPY profiles /build/profiles
COPY schema /build/schema
COPY config /build/config

RUN mvn -DskipTests clean package

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/validator \
    && unzip -q target/*-bin.zip -d /opt/validator

FROM eclipse-temurin:8-jre

WORKDIR /opt/validator/ddex-message-validator-api-1.0-SNAPSHOT
COPY --from=build /opt/validator/ /opt/validator/
COPY --from=build /build/schema /opt/validator/ddex-message-validator-api-1.0-SNAPSHOT/schema
COPY --from=build /build/profiles /opt/validator/ddex-message-validator-api-1.0-SNAPSHOT/profiles
COPY --from=build /build/config /opt/validator/ddex-message-validator-api-1.0-SNAPSHOT/config

EXPOSE 6060

CMD ["./bin/start-api", "6060"]
