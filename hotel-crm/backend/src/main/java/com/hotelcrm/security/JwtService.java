package com.hotelcrm.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

/** Issues and validates short lived access tokens and rotating refresh tokens (HS256). */
@Slf4j
@Service
public class JwtService {

    public static final String TOKEN_TYPE_ACCESS = "access";
    public static final String TOKEN_TYPE_REFRESH = "refresh";

    private final JwtProperties properties;
    private final SecretKey key;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        byte[] secret = properties.secret() == null ? new byte[0] : properties.secret().getBytes(StandardCharsets.UTF_8);
        if (secret.length < 32) {
            throw new IllegalStateException("JWT_SECRET must be at least 32 bytes long");
        }
        this.key = Keys.hmacShaKeyFor(secret);
    }

    public String generateAccessToken(AppUserPrincipal principal) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(principal.getEmail())
                .issuer(properties.issuer())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(properties.accessTokenTtlMinutes() * 60)))
                .claim("uid", principal.getId())
                .claim("role", principal.getRole().name())
                .claim("tv", principal.getTokenVersion())
                .claim("typ", TOKEN_TYPE_ACCESS)
                .signWith(key)
                .compact();
    }

    public String generateRefreshToken(AppUserPrincipal principal) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(principal.getEmail())
                .issuer(properties.issuer())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(properties.refreshTokenTtlDays() * 24 * 3600)))
                .claim("uid", principal.getId())
                .claim("tv", principal.getTokenVersion())
                .claim("typ", TOKEN_TYPE_REFRESH)
                .signWith(key)
                .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .requireIssuer(properties.issuer())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public Claims parseAccessToken(String token) {
        Claims claims = parse(token);
        if (!TOKEN_TYPE_ACCESS.equals(claims.get("typ", String.class))) {
            throw new JwtException("Not an access token");
        }
        return claims;
    }

    public Claims parseRefreshToken(String token) {
        Claims claims = parse(token);
        if (!TOKEN_TYPE_REFRESH.equals(claims.get("typ", String.class))) {
            throw new JwtException("Not a refresh token");
        }
        return claims;
    }

    public boolean isValid(String token) {
        try {
            parse(token);
            return true;
        } catch (JwtException | IllegalArgumentException ex) {
            return false;
        }
    }

    public long accessTokenTtlSeconds() {
        return properties.accessTokenTtlMinutes() * 60;
    }

    public long refreshTokenTtlSeconds() {
        return properties.refreshTokenTtlDays() * 24 * 3600;
    }
}
