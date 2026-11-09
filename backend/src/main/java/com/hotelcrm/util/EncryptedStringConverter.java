package com.hotelcrm.util;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/** Transparently encrypts/decrypts a text column using {@link FieldCipher}. */
@Converter
public class EncryptedStringConverter implements AttributeConverter<String, String> {

    @Override
    public String convertToDatabaseColumn(String attribute) {
        return attribute == null || attribute.isBlank() ? null : FieldCipher.encrypt(attribute);
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        return dbData == null || dbData.isBlank() ? null : FieldCipher.decrypt(dbData);
    }
}
