package com.investmenttracker.component.masking;

import com.fasterxml.jackson.annotation.JacksonAnnotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Anotación para marcar un campo de un DTO como sensible.
 * El valor se ofusca en el JSON de salida según el {@link MaskType}.
 * La ofuscación se omite si {@link MaskingContext#isEnabled()} es false.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
@JacksonAnnotation
public @interface Masked {
    MaskType value();
}
