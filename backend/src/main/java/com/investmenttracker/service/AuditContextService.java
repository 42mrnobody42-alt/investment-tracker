package com.investmenttracker.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Servicio para forzar el usuario de auditoría en la conexión PostgreSQL
 * cuando no hay un JWT emitido (por ejemplo, durante el login).
 *
 * <p>El wrapper {@code AuditUserAwareDataSource} puebla {@code app.audit_user}
 * a partir del {@code SecurityContextHolder}. Sin embargo, durante el login
 * todavía no existe autenticación, por lo que el wrapper pondría
 * {@code 'desconocido'}. Este servicio permite sobrescribir ese valor dentro
 * de la misma transacción para registrar al usuario que se está logueando.
 *
 * <p><b>Importante:</b> Debe invocarse DENTRO de una transacción activa
 * (por eso {@code Propagation.MANDATORY}) para garantizar que el
 * {@code set_config} afecte la misma conexión que usará Hibernate.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuditContextService {

    private static final String SET_AUDIT_USER_SQL =
            "SELECT set_config('app.audit_user', ?, false)";

    private final JdbcTemplate jdbcTemplate;

    @Transactional(propagation = Propagation.MANDATORY)
    public void setCurrentUser(String username) {
        if (username == null || username.isBlank()) {
            log.warn("setCurrentUser llamado con username vacío; se ignora");
            return;
        }
        jdbcTemplate.queryForObject(SET_AUDIT_USER_SQL, String.class, username);
        log.debug("app.audit_user forzado a '{}'", username);
    }
}
