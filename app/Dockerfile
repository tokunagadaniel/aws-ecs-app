FROM maven:3.5.2-jdk-8-alpine AS MAVEN_BUILD
LABEL maintainer Daniel Tokunaga
COPY pom.xml /build/
COPY src /build/src/
WORKDIR /build/
RUN mvn clean package
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=MAVEN_BUILD /build/target/aws-ecs-app-1.0.0.jar /app/
COPY application-aws.yml /app/application.yml
ENTRYPOINT ["java", "-jar", "aws-ecs-app-1.0.0.jar"]