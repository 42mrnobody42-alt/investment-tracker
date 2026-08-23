package com.investmenttracker.service;

import com.investmenttracker.model.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    @Value("${refresh-token.access-token-ttl-minutes}")
    private Long accessTokenTtlMinutes;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId().toString());
        claims.put("username", user.getUsername());
        claims.put("email", user.getEmail());
        claims.put("roles", user.getRoles().stream()
            .map(role -> role.getNombre())
            .collect(Collectors.toList()));

        Date now = new Date();
        Date expirationDate = new Date(now.getTime() + (accessTokenTtlMinutes * 60 * 1000));

        return Jwts.builder()
            .id(UUID.randomUUID().toString())
            .claims(claims)
            .subject(user.getUsername())
            .issuedAt(now)
            .expiration(expirationDate)
            .signWith(getSigningKey())
            .compact();
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    public String extractUsername(String token) {
        return extractAllClaims(token).getSubject();
    }

    public boolean isTokenExpired(String token) {
        return extractAllClaims(token).getExpiration().before(new Date());
    }

    public boolean validateToken(String token, String username) {
        final String extractedUsername = extractUsername(token);
        return (extractedUsername.equals(username) && !isTokenExpired(token));
    }

    public Long getExpirationTime() {
        return accessTokenTtlMinutes * 60 * 1000;
    }

    public Long getAccessTokenTtlMinutes() {
        return accessTokenTtlMinutes;
    }
}
