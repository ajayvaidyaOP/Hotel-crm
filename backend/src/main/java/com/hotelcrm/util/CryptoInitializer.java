package com.hotelcrm.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/** Bootstraps the static field cipher with the environment supplied encryption key. */
@Slf4j
@Component
public class CryptoInitializer {

    private final String encryptionKey;

    public CryptoInitializer(@Value("${app.security.encryption-key}") String encryptionKey) {
        this.encryptionKey = encryptionKey;
        FieldCipher.initialise(encryptionKey);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        FieldCipher.initialise(encryptionKey);
        log.info("Guest data field encryption initialised");
    }
}
