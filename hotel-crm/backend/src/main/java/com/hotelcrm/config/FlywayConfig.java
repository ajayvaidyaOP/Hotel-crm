package com.hotelcrm.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.flyway.FlywayConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Adds the demo seed location only when APP_SEED_ENABLED=true, so production databases can be
 * created from the exact same migration history without demo rows.
 */
@Slf4j
@Configuration
public class FlywayConfig {

    @Value("${app.seed.enabled:false}")
    private boolean seedEnabled;

    @Bean
    public FlywayConfigurationCustomizer flywayConfigurationCustomizer() {
        return configuration -> {
            if (seedEnabled) {
                log.info("Flyway: demo seed data enabled (classpath:db/seed)");
                configuration.locations("classpath:db/migration", "classpath:db/seed");
            } else {
                log.info("Flyway: demo seed data disabled");
                configuration.locations("classpath:db/migration");
            }
        };
    }
}
