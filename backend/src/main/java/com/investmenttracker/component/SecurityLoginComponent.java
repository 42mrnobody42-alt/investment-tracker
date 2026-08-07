package com.investmenttracker.component;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

@Component
@Slf4j
public class SecurityLoginComponent {

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    
    // Patrón: al menos 8 caracteres, 1 mayúscula, 1 carácter especial
    // Caracteres especiales permitidos: $ # @ ? ! % & * + - _ = . : , ; ( ) [ ] { } < > ~ ^
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[A-Z])(?=.*[$#@?!%&*+\\-_=.:,;()\\[\\]{}<>~^])[A-Za-z0-9$#@?!%&*+\\-_=.:,;()\\[\\]{}<>~^]{8,}$"
    );
    
    // Caracteres prohibidos: comillas dobles y simples
    private static final Pattern FORBIDDEN_CHARS = Pattern.compile("[\"']");

    /**
     * Encripta una contraseña con BCrypt
     */
    public String encryptPassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    /**
     * Verifica si una contraseña en texto plano coincide con el hash
     */
    public boolean verifyPassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    /**
     * Valida que la contraseña cumpla con los criterios de seguridad:
     * - Mínimo 8 caracteres
     * - Al menos 1 mayúscula
     * - Al menos 1 carácter especial
     * - Sin comillas dobles ni simples
     */
    public boolean isValidPassword(String password) {
        if (password == null) {
            return false;
        }
        
        // Verificar caracteres prohibidos
        if (FORBIDDEN_CHARS.matcher(password).find()) {
            log.warn("Contraseña contiene caracteres prohibidos (comillas)");
            return false;
        }
        
        // Verificar patrón de complejidad
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            log.warn("Contraseña no cumple con los criterios de complejidad");
            return false;
        }
        
        return true;
    }

    /**
     * Verifica que dos contraseñas sean idénticas (caseSensitive)
     */
    public boolean passwordsMatch(String password1, String password2) {
        if (password1 == null || password2 == null) {
            return false;
        }
        return password1.equals(password2);
    }

    /**
     * Valida que ningún campo obligatorio sea null o vacío
     */
    public boolean hasEmptyFields(String... fields) {
        for (String field : fields) {
            if (field == null || field.trim().isEmpty()) {
                return true;
            }
        }
        return false;
    }

    public PasswordEncoder getPasswordEncoder() {
        return passwordEncoder;
    }
}
