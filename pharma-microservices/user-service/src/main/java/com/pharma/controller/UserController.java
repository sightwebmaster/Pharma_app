package com.pharma.controller;

import com.pharma.dto.*;
import com.pharma.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    // ═══════════════════════════════════════════════════════════════════════
    //  INSCRIPTION PUBLIQUE — Pas de JWT requis
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * POST /api/users/register
     * Crée un compte dans Keycloak depuis le backend (pas de CORS).
     * Accessible sans token JWT (permitAll dans SecurityConfig).
     */
    @PostMapping("/register")
    public ResponseEntity<Map<String, String>> register(
            @RequestBody RegisterRequest req) {
        try {
            userService.registerUser(req);
            return ResponseEntity.ok(Map.of("message", "Compte créé avec succès"));
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            // Email déjà utilisé → Keycloak retourne 409
            if (msg.contains("409") || msg.contains("KEYCLOAK_409")) {
                return ResponseEntity.status(409)
                    .body(Map.of("error", "Email déjà utilisé"));
            }
            log.error("Erreur register: {}", msg);
            return ResponseEntity.status(500)
                .body(Map.of("error", "Erreur serveur: " + msg));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-2 / SCRUM-11 — Sync après login Keycloak
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * POST /api/users/sync
     * Appelé depuis Flutter juste après le login Keycloak.
     * Crée le profil local si c'est le premier login, sinon retourne l'existant.
     */
    @PostMapping("/sync")
    public ResponseEntity<UserDTO> syncProfile(Authentication auth) {
        if (!(auth instanceof JwtAuthenticationToken jwtAuth)) {
            return ResponseEntity.badRequest().build();
        }

        String keycloakId = jwtAuth.getName();
        String email      = jwtAuth.getToken().getClaimAsString("email");
        String role       = extractRole(jwtAuth);

        log.info("Sync profil: keycloakId={} email={} role={}", keycloakId, email, role);
        return ResponseEntity.ok(userService.createOrUpdateUser(keycloakId, email, role));
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-10 — Mon profil
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * GET /api/users/me
     */
    @GetMapping("/me")
    public ResponseEntity<UserDTO> getProfile(Authentication auth) {
        return ResponseEntity.ok(userService.getCurrentUser(auth));
    }

    /**
     * PUT /api/users/me
     */
    @PutMapping("/me")
    public ResponseEntity<UserDTO> updateProfile(
            @RequestBody UpdateProfileRequest req,
            Authentication auth) {
        return ResponseEntity.ok(userService.updateProfile(req, auth));
    }

    /**
     * PUT /api/users/me/fcm-token
     */
    @PutMapping("/me/fcm-token")
    public ResponseEntity<Void> updateFcmToken(
            @RequestBody Map<String, String> body,
            Authentication auth) {
        userService.updateFcmToken(body.get("fcmToken"), auth);
        return ResponseEntity.ok().build();
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-2 — Profil médical : Allergies
    // ═══════════════════════════════════════════════════════════════════════

    @GetMapping("/me/allergies")
    @PreAuthorize("hasRole('PATIENT')")
    public ResponseEntity<List<AllergyDTO>> getAllergies(Authentication auth) {
        return ResponseEntity.ok(userService.getAllergies(auth));
    }

    @PostMapping("/me/allergies")
    @PreAuthorize("hasRole('PATIENT')")
    public ResponseEntity<AllergyDTO> addAllergy(
            @Valid @RequestBody AllergyDTO.Request req,
            Authentication auth) {
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(userService.addAllergy(req, auth));
    }

    @DeleteMapping("/me/allergies/{id}")
    @PreAuthorize("hasRole('PATIENT')")
    public ResponseEntity<Void> removeAllergy(
            @PathVariable UUID id,
            Authentication auth) {
        userService.removeAllergy(id, auth);
        return ResponseEntity.noContent().build();
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-17 — Admin : gérer les comptes pharmaciens
    // ═══════════════════════════════════════════════════════════════════════

    @GetMapping("/pharmaciens")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserDTO>> getAllPharmaciens() {
        return ResponseEntity.ok(userService.getAllPharmaciens());
    }

    @GetMapping("/patients")
    @PreAuthorize("hasAnyRole('PHARMACIEN','ADMIN')")
    public ResponseEntity<List<UserDTO>> getAllPatients() {
        return ResponseEntity.ok(userService.getAllPatients());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ENDPOINTS INTERNES
    // ═══════════════════════════════════════════════════════════════════════

    @GetMapping("/internal/{keycloakId}")
    public ResponseEntity<UserDTO> getByKeycloakId(@PathVariable String keycloakId) {
        return userService.getInternalUser(keycloakId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  HELPER PRIVÉ
    // ═══════════════════════════════════════════════════════════════════════

    private String extractRole(JwtAuthenticationToken jwtAuth) {
        Map<String, Object> realmAccess = jwtAuth.getToken().getClaimAsMap("realm_access");
        if (realmAccess != null) {
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            if (roles != null) {
                if (roles.contains("ADMIN"))      return "ADMIN";
                if (roles.contains("PHARMACIEN")) return "PHARMACIEN";
            }
        }
        return "PATIENT";
    }
}