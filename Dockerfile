# 第一阶段：构建前端
FROM node:20-alpine AS ui-builder
WORKDIR /app/ui
COPY ui/package.json ui/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY ui/ ./
RUN pnpm run build

# 第���阶段：构建后端
FROM eclipse-temurin:21-jre-jammy AS backend-builder
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven && mvn clean package -DskipTests

# 第三阶段：运行
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# 复制后端 JAR
COPY --from=backend-builder /app/console/target/console-1.0-SNAPSHOT.jar app.jar

# 复制前端静态文件到 Nginx 或 Spring Boot 静态目录
COPY --from=ui-builder /app/ui/dist /app/static

# 复制配置文件
COPY application-dev.yml /app/config/

EXPOSE 8080

ENTRYPOINT ["java", "-Dspring.config.location=file:/app/config/application-dev.yml", "-jar", "app.jar"]
