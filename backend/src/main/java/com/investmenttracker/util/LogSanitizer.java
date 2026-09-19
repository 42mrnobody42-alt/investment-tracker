package com.investmenttracker.util;

import com.investmenttracker.config.SensitiveFieldsProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * Sanitiza valores antes de escribirlos en logs.
 * Si el nombre del campo está en la lista negra ({@code security.sensitive-fields}),
 * retorna {@code [PROTEGIDO]} en su lugar.
 */
@Component
@RequiredArgsConstructor
public class LogSanitizer {

    private static final String MASK = "[PROTEGIDO]";

    private final SensitiveFieldsProperties properties;

    public String sanitize(String fieldName, Object value) {
        if (properties.isSensitive(fieldName)) {
            return MASK;
        }
        return value == null ? "null" : String.valueOf(value);
    }
}
