package com.pharma.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverter;
import org.springframework.security.web.server.SecurityWebFilterChain;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.Map;

@Configuration
@EnableWebFluxSecurity
public class GatewaySecurityConfig {

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeExchange(exchanges -> exchanges

                // ── Endpoints publics (pas de JWT requis) ─────────────────
                .pathMatchers("/actuator/**").permitAll()
                .pathMatchers("/api/public/**").permitAll()
                .pathMatchers("/api/users/internal/**").permitAll()
                .pathMatchers("/api/users/register").permitAll()  // ← INSCRIPTION

                // ── Tout le reste nécessite un JWT Keycloak valide ─────────
                .anyExchange().authenticated()
            )
            .oauth2ResourceServer(oauth2 ->
                oauth2.jwt(jwt ->
                    jwt.jwtAuthenticationConverter(keycloakConverter())
                )
            );

        return http.build();
    }

    private ReactiveJwtAuthenticationConverter keycloakConverter() {
        var converter = new ReactiveJwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
            if (realmAccess == null) return Flux.empty();

            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            if (roles == null) return Flux.empty();

            return Flux.fromIterable(roles)
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role));
        });
        return converter;
    }
}