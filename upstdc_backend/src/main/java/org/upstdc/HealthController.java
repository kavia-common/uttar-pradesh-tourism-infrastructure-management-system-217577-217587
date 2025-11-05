package org.upstdc;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * HealthController exposes simple health endpoints for runtime liveness checks.
 */
@RestController
public class HealthController {

    // PUBLIC_INTERFACE
    /**
     * Basic health endpoint for external systems that do not use Spring Actuator.
     * Returns a simple JSON map with status=UP when the service is running.
     *
     * @return Map with a single key "status" and value "UP".
     */
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }
}
