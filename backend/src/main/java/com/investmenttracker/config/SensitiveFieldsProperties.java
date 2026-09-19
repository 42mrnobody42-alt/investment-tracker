package com.investmenttracker.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

/**
 * Lista configurable de campos cuyo valor NUNCA debe aparecer en logs.
 * Editable desde {@code application.yml} bajo la clave {@code security.sensitive-fields}.
 */
@Configuration
@ConfigurationProperties(prefix = "security")
@Getter
@Setter
public class SensitiveFieldsProperties {

    private Set<String> sensitiveFields = new HashSet<>();

    public boolean isSensitive(String fieldName) {
        if (fieldName == null) {
            return false;
        }
        return sensitiveFields.contains(fieldName.toLowerCase(Locale.ROOT));
    }
}
