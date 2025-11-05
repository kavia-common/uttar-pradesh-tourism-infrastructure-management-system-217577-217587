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
