package org.upstdc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point for the UPSTDC backend Spring Boot application.
 */
@SpringBootApplication
public class Application {

    // PUBLIC_INTERFACE
    /**
     * Boots the Spring application.
     * Ensures that configuration in application.properties binds to the desired port.
     *
     * @param args CLI arguments
     */
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
