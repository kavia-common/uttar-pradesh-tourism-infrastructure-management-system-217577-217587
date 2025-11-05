#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
mkdir -p "$WORKSPACE" && cd "$WORKSPACE"
cat > pom.xml <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
    <relativePath/>
  </parent>
  <groupId>org.upstdc</groupId>
  <artifactId>upstdc-backend</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <properties>
    <java.version>17</java.version>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
    <!-- Explicit JUnit engine to avoid platform resolution issues in some environments -->
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter-engine</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>app</finalName>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
POM
mkdir -p src/main/java/org/upstdc src/main/resources src/test/java/org/upstdc
cat > src/main/java/org/upstdc/Application.java <<'JAVA'
package org.upstdc;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class Application { public static void main(String[] args) { SpringApplication.run(Application.class, args); } }
JAVA
cat > src/main/java/org/upstdc/HealthController.java <<'JAVA'
package org.upstdc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
@RestController
public class HealthController { @GetMapping("/health") public Map<String,String> health() { return Map.of("status","UP"); } }
JAVA
cat > src/main/resources/application.properties <<'PROPS'
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:h2:mem:upstdc;DB_CLOSE_DELAY=-1}
spring.datasource.driver-class-name=org.h2.Driver
spring.h2.console.enabled=true
logging.level.root=INFO
server.port=8080
PROPS
cat > src/test/java/org/upstdc/HealthIntegrationTest.java <<'TEST'
package org.upstdc;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import static org.assertj.core.api.Assertions.assertThat;
import java.util.Map;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class HealthIntegrationTest {
  @Autowired
  TestRestTemplate rest;
  @Test
  void healthEndpoint() {
    Map resp = rest.getForObject("/health", Map.class);
    assertThat(resp).containsEntry("status","UP");
  }
}
TEST
cat > .gitignore <<'GIT'
/target/
GIT
