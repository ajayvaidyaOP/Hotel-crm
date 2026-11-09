package com.hotelcrm.util;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * AES-256/GCM helper for encrypting sensitive guest data (id proof numbers) at rest.
 * The key is supplied through APP_ENCRYPTION_KEY and initialised once at startup.
 */
public final class FieldCipher {

    private static final int IV_LENGTH = 12;
    private static final int TAG_BITS = 128;
    private static final SecureRandom RANDOM = new SecureRandom();
    private static volatile SecretKeySpec key;

    private FieldCipher() {
    }

    public static void initialise(String rawKey) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashed = digest.digest(rawKey.getBytes(StandardCharsets.UTF_8));
            key = new SecretKeySpec(hashed, "AES");
        } catch (Exception e) {
            throw new IllegalStateException("Unable to initialise field cipher", e);
        }
    }

    public static boolean isReady() {
        return key != null;
    }

    public static String encrypt(String plain) {
        if (plain == null || plain.isBlank()) {
            return null;
        }
        if (!isReady()) {
            throw new IllegalStateException("Field cipher not initialised");
        }
        try {
            byte[] iv = new byte[IV_LENGTH];
            RANDOM.nextBytes(iv);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(TAG_BITS, iv));
            byte[] cipherText = cipher.doFinal(plain.getBytes(StandardCharsets.UTF_8));
            byte[] payload = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, payload, 0, iv.length);
            System.arraycopy(cipherText, 0, payload, iv.length, cipherText.length);
            return Base64.getEncoder().encodeToString(payload);
        } catch (Exception e) {
            throw new IllegalStateException("Unable to encrypt field", e);
        }
    }

    public static String decrypt(String payload) {
        if (payload == null || payload.isBlank() || !isReady()) {
            return null;
        }
        try {
            byte[] decoded = Base64.getDecoder().decode(payload);
            byte[] iv = new byte[IV_LENGTH];
            byte[] cipherText = new byte[decoded.length - IV_LENGTH];
            System.arraycopy(decoded, 0, iv, 0, IV_LENGTH);
            System.arraycopy(decoded, IV_LENGTH, cipherText, 0, cipherText.length);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(TAG_BITS, iv));
            return new String(cipher.doFinal(cipherText), StandardCharsets.UTF_8);
        } catch (Exception e) {
            return null;
        }
    }

    public static String last4(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.length() <= 4 ? trimmed : trimmed.substring(trimmed.length() - 4);
    }
}
