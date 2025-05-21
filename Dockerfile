# Build app with a base image
FROM maven:3.8.7-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Use Tomcat as base image to deploy the app
FROM tomcat:9.0-jdk17

# Remove default web apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# EXPOSE port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

