# ==========================
# 1️⃣ Build Stage - Maven
# ==========================
FROM maven:3.9.9-eclipse-temurin-21 AS build

# Set working directory inside the build container
WORKDIR /build

# Copy pom.xml and download dependencies first (for better caching)
COPY pom.xml .
COPY src ./src

# Build the project using Maven (use fast-jar packaging for Quarkus)
RUN mvn clean package -DskipTests -Dquarkus.package.type=fast-jar

# ==========================
# 2️⃣ Runtime Stage - JRE only
# ==========================
FROM eclipse-temurin:21-jre-alpine

ENV LANGUAGE="en_US:en"
WORKDIR /work/

# Copy Quarkus fast-jar output from the Maven build stage
COPY --from=build /build/target/quarkus-app/lib/ /work/lib/
COPY --from=build /build/target/quarkus-app/*.jar /work/
COPY --from=build /build/target/quarkus-app/app/ /work/app/
COPY --from=build /build/target/quarkus-app/quarkus/ /work/quarkus/

# Expose the Quarkus port (as configured)
EXPOSE 18181

# Set Quarkus runtime options
ENV JAVA_OPTS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"

# Run the Quarkus app
ENTRYPOINT ["java","-jar","/work/quarkus-run.jar"]
