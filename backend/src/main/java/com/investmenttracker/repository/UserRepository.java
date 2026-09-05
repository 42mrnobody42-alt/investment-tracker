package com.investmenttracker.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.investmenttracker.model.entity.User;

/**
 * Repositorio para la entidad User.
 * 
 * <p>
 * La base de datos tiene restricciones de unicidad case-insensitive sobre
 * {@code username} y {@code email}
 * mediante índices funcionales con {@code LOWER()}. Por lo tanto, ambos campos
 * son únicos sin importar
 * mayúsculas o minúsculas.
 * </p>
 * 
 * <p>
 * Para mantener la coherencia, las operaciones de búsqueda deberían ser también
 * case-insensitive.
 * Por eso se proveen los métodos {@code findByUsernameIgnoreCase} y
 * {@code findByEmailIgnoreCase}
 * como alternativa a los homólogos exactos ({@code findByUsername} y
 * {@code findByEmail}).
 * </p>
 * 
 * <ul>
 * <li>{@code findByUsername(String)} → Búsqueda exacta (case-sensitive).</li>
 * <li>{@code findByUsernameIgnoreCase(String)} → Búsqueda insensible a
 * mayúsculas/minúsculas.</li>
 * <li>{@code findByEmail(String)} → Búsqueda exacta (case-sensitive).</li>
 * <li>{@code findByEmailIgnoreCase(String)} → Búsqueda insensible a
 * mayúsculas/minúsculas.</li>
 * </ul>
 * 
 * <p>
 * <b>Nota:</b> Para el login y otras validaciones de existencia se recomienda
 * usar los métodos
 * {@code IgnoreCase}, ya que coinciden con la restricción de unicidad de la
 * base de datos y evitan
 * errores de capitalización por parte del usuario.
 * </p>
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    /**
     * Busca un usuario por nombre de usuario exacto (case-sensitive).
     * 
     * @param username nombre de usuario exacto
     * @return Optional con el usuario si existe
     */
    Optional<User> findByUsername(String username);

    /**
     * Busca un usuario por nombre de usuario sin importar mayúsculas/minúsculas
     * (case-insensitive).
     * 
     * @param username nombre de usuario (cualquier capitalización)
     * @return Optional con el usuario si existe
     */
    Optional<User> findByUsernameIgnoreCase(String username);

    /**
     * Busca un usuario por correo electrónico exacto (case-sensitive).
     * 
     * @param email correo electrónico exacto
     * @return Optional con el usuario si existe
     */
    Optional<User> findByEmail(String email);

    /**
     * Busca un usuario por correo electrónico sin importar mayúsculas/minúsculas
     * (case-insensitive).
     * 
     * @param email correo electrónico (cualquier capitalización)
     * @return Optional con el usuario si existe
     */
    Optional<User> findByEmailIgnoreCase(String email);

    /**
     * Verifica si existe un usuario con el nombre de usuario exacto
     * (case-sensitive).
     * 
     * @param username nombre de usuario exacto
     * @return true si existe
     */
    boolean existsByUsername(String username);

    /**
     * Verifica si existe un usuario con el correo electrónico exacto
     * (case-sensitive).
     * 
     * @param email correo electrónico exacto
     * @return true si existe
     */
    boolean existsByEmail(String email);
}
