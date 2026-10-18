# ---------- Stage 1: build the WAR with Maven ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline || true
COPY src ./src
RUN mvn -B -q -DskipTests clean package

# ---------- Stage 2: run on Tomcat ----------
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/* \
 && groupadd -r tomcat && useradd -r -g tomcat tomcat

COPY --from=build /app/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
RUN chown -R tomcat:tomcat /usr/local/tomcat

USER tomcat
EXPOSE 8080
CMD ["catalina.sh", "run"]
