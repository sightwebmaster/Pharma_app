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
     * Retourne le profil de l'utilisateur connecté.
     */
    @GetMapping("/me")
    public ResponseEntity<UserDTO> getProfile(Authentication auth) {
        return ResponseEntity.ok(userService.getCurrentUser(auth));
    }

    /**
     * PUT /api/users/me
     * Met à jour le profil (prénom, nom, téléphone, date de naissance).
     */
    @PutMapping("/me")
    public ResponseEntity<UserDTO> updateProfile(
            @RequestBody UpdateProfileRequest req,
            Authentication auth) {
        return ResponseEntity.ok(userService.updateProfile(req, auth));
    }

    /**
     * PUT /api/users/me/fcm-token
     * Enregistre le token Firebase pour les notifications push (Sprint 3).
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

    /**
     * GET /api/users/me/allergies
     * Retourne la liste des allergies du patient connecté.
     */
    @GetMapping("/me/allergies")
    @PreAuthorize("hasRole('PATIENT')")
    public ResponseEntity<List<AllergyDTO>> getAllergies(Authentication auth) {
        return ResponseEntity.ok(userService.getAllergies(auth));
    }

    /**
     * POST /api/users/me/allergies
     * Ajoute une allergie au profil médical du patient.
     */
    @PostMapping("/me/allergies")
    @PreAuthorize("hasRole('PATIENT')")
    public ResponseEntity<AllergyDTO> addAllergy(
            @Valid @RequestBody AllergyDTO.Request req,
            Authentication auth) {
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(userService.addAllergy(req, auth));
    }

    /**
     * DELETE /api/users/me/allergies/{id}
     * Supprime une allergie du profil médical du patient.
     */
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

    /**
     * GET /api/users/pharmaciens
     * Liste tous les pharmaciens (accès ADMIN uniquement).
     */
    @GetMapping("/pharmaciens")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserDTO>> getAllPharmaciens() {
        return ResponseEntity.ok(userService.getAllPharmaciens());
    }

    /**
     * GET /api/users/patients
     * Liste tous les patients (accès PHARMACIEN ou ADMIN).
     */
    @GetMapping("/patients")
    @PreAuthorize("hasAnyRole('PHARMACIEN','ADMIN')")
    public ResponseEntity<List<UserDTO>> getAllPatients() {
        return ResponseEntity.ok(userService.getAllPatients());
    }

    /**
     * DELETE /api/users/{id}
     * Supprime un compte utilisateur (accès ADMIN uniquement).
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ENDPOINTS INTERNES (inter-services, pas derrière la gateway auth)
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * GET /api/users/internal/{keycloakId}
     * Utilisé par medication-service / recommendation-service (Sprint 2).
     * Pas d'auth requise car appelé de service à service en interne.
     */
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
