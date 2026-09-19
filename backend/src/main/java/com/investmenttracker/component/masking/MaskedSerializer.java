package com.investmenttracker.component.masking;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.BeanProperty;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.ser.ContextualSerializer;

import java.io.IOException;

/**
 * Serializer que aplica ofuscación sobre un campo anotado con {@link Masked}.
 * Si el {@link MaskingContext} está deshabilitado, escribe el valor real.
 */
public class MaskedSerializer extends JsonSerializer<Object> implements ContextualSerializer {

    private final MaskType type;

    public MaskedSerializer() {
        this(null);
    }

    public MaskedSerializer(MaskType type) {
        this.type = type;
    }

    @Override
    public void serialize(Object value, JsonGenerator gen, SerializerProvider serializers) throws IOException {
        if (value == null) {
            gen.writeNull();
            return;
        }

        // Si no hay tipo o el contexto está deshabilitado → valor real
        if (type == null || !MaskingContext.isEnabled()) {
            writeRaw(value, gen);
            return;
        }

        // Valor ofuscado
        gen.writeString(DataMasking.mask(value, type));
    }

    private void writeRaw(Object value, JsonGenerator gen) throws IOException {
        if (value instanceof Number n) {
            gen.writeNumber(n.longValue());
        } else if (value instanceof Boolean b) {
            gen.writeBoolean(b);
        } else {
            gen.writeString(String.valueOf(value));
        }
    }

    @Override
    public JsonSerializer<?> createContextual(SerializerProvider prov, BeanProperty property)
            throws JsonMappingException {
        if (property == null) {
            return this;
        }
        Masked ann = property.getAnnotation(Masked.class);
        if (ann == null) {
            return this;
        }
        return new MaskedSerializer(ann.value());
    }
}
