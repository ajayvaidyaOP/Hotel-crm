# ---------- build ----------
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /workspace
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x gradlew && ./gradlew --no-daemon dependencies > /dev/null 2>&1 || true
COPY src ./src
RUN ./gradlew --no-daemon clean bootJar -x test

# ---------- runtime ----------
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
    && useradd -r -u 1001 -m appuser
COPY --from=build /workspace/build/libs/*.jar app.jar
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseG1GC"
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=5 \
    CMD curl -fsS http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
