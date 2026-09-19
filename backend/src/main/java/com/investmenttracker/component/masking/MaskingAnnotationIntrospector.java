package com.investmenttracker.component.masking;

import com.fasterxml.jackson.databind.introspect.Annotated;
import com.fasterxml.jackson.databind.introspect.JacksonAnnotationIntrospector;

/**
 * Introspector que detecta {@link Masked} y devuelve {@link MaskedSerializer}
 * como serializer para el campo. Extiende {@link JacksonAnnotationIntrospector}
 * para preservar el comportamiento estándar de Jackson.
 */
public class MaskingAnnotationIntrospector extends JacksonAnnotationIntrospector {

    @Override
    public Object findSerializer(Annotated a) {
        if (a.getAnnotation(Masked.class) != null) {
            return MaskedSerializer.class;
        }
        return super.findSerializer(a);
    }
}
