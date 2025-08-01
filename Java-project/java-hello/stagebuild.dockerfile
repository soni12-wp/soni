# First stage: Build the application using Maven
FROM maven:3.9.9-amazoncorretto-17-alpine AS build

# Set the working directory to /build
WORKDIR /build

# Copy the pom.xml and source code
COPY . .

# Package the application
RUN mvn clean package

# Second stage: Create the runtime image
FROM openjdk:17-alpine

# Set the working directory to /app
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /build/target/hello-world-1.0.0-SNAPSHOT.jar /app/hello-world.jar

# Set the entrypoint to run the JAR file
ENTRYPOINT ["java", "-jar", "/app/hello-world.jar"]