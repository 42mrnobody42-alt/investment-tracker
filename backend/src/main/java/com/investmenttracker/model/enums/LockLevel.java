package com.investmenttracker.model.enums;

import lombok.Getter;

@Getter
public enum LockLevel {
    
    NONE(0, 0, "Sin bloqueo"),
    FIRST(1, 5, "Primer bloqueo: 5 minutos"),
    SECOND(2, 15, "Segundo bloqueo: 15 minutos"),
    THIRD(3, 30, "Tercer bloqueo: 30 minutos"),
    FOURTH(4, 60, "Cuarto bloqueo: 1 hora"),
    FIFTH(5, 720, "Quinto bloqueo: 12 horas"),
    SIXTH(6, 1440, "Sexto bloqueo: 24 horas"),
    PERMANENT(7, -1, "Bloqueo permanente");
    
    private final int level;
    private final int durationMinutes; // -1 para permanente
    private final String description;
    
    LockLevel(int level, int durationMinutes, String description) {
        this.level = level;
        this.durationMinutes = durationMinutes;
        this.description = description;
    }
    
    public static LockLevel fromLevel(int level) {
        for (LockLevel lockLevel : values()) {
            if (lockLevel.level == level) {
                return lockLevel;
            }
        }
        return level >= PERMANENT.level ? PERMANENT : NONE;
    }
    
    public LockLevel next() {
        return fromLevel(this.level + 1);
    }
}
