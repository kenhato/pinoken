FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY target/springboot-jsp-app-0.0.1-SNAPSHOT.war app.war

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.war"]
