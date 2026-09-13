package com.investmenttracker.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.datasource.DelegatingDataSource;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Wrapper del DataSource que propaga el usuario autenticado (extraído del JWT
 * por {@code JwtAuthFilter} y almacenado en {@code SecurityContextHolder}) hacia
 * la sesión PostgreSQL mediante {@code set_config('app.audit_user', ...)}.
 *
 * <p>El trigger {@code trg_audit_usuarios} lee dicho valor con
 * {@code current_setting('app.audit_user', true)} para poblar la columna
 * {@code usuario_aplicacion} de la tabla {@code auditoria_usuarios}.
 *
 * <p>Si no hay autenticación activa, se usa el valor {@code 'desconocido'}.
 *
 * <p><b>Nota:</b> El valor se establece a nivel de sesión ({@code is_local=false})
 * y se sobrescribe en cada préstamo de conexión ({@code getConnection()}), por lo
 * que no hay riesgo de arrastrar el usuario de una petición a otra.
 */
@Slf4j
public class AuditUserAwareDataSource extends DelegatingDataSource {

    private static final String SET_AUDIT_USER_SQL =
            "SELECT set_config('app.audit_user', ?, false)";

    private static final String UNKNOWN_USER = "desconocido";
    private static final String ANONYMOUS_USER = "anonymousUser";

    public AuditUserAwareDataSource(DataSource targetDataSource) {
        super(targetDataSource);
    }

    @Override
    public Connection getConnection() throws SQLException {
        Connection conn = super.getConnection();
        applyAuditUser(conn);
        return conn;
    }

    @Override
    public Connection getConnection(String username, String password) throws SQLException {
        Connection conn = super.getConnection(username, password);
        applyAuditUser(conn);
        return conn;
    }

    private void applyAuditUser(Connection conn) {
        String auditUser = resolveAuditUser();
        try (PreparedStatement ps = conn.prepareStatement(SET_AUDIT_USER_SQL)) {
            ps.setString(1, auditUser);
            ps.execute();
            if (log.isTraceEnabled()) {
                log.trace("app.audit_user establecido a '{}'", auditUser);
            }
        } catch (SQLException e) {
            // No propagar: si falla, el trigger usará 'desconocido' como fallback
            log.warn("No se pudo establecer app.audit_user: {}", e.getMessage());
        }
    }

    private String resolveAuditUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return UNKNOWN_USER;
        }
        String name = auth.getName();
        if (name == null || name.isBlank() || ANONYMOUS_USER.equals(name)) {
            return UNKNOWN_USER;
        }
        return name;
    }
}
