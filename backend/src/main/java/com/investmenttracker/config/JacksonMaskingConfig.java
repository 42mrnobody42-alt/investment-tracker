package com.investmenttracker.config;

import com.investmenttracker.component.masking.MaskingAnnotationIntrospector;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Registra el introspector de Jackson que aplica {@code @Masked}
 * en la serialización de los DTOs de respuesta.
 */
@Configuration
public class JacksonMaskingConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer maskingCustomizer() {
        return builder -> builder.postConfigurer(mapper ->
                mapper.setAnnotationIntrospector(new MaskingAnnotationIntrospector()));
    }
}
