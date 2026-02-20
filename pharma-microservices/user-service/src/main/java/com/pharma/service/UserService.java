package com.pharma.service;

import com.pharma.dto.*;
import com.pharma.entity.*;
import com.pharma.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class UserService {

    private final UserRepository         userRepository;
    private final AllergyRepository      allergyRepository;
    private final FamilyMemberRepository familyMemberRepository;

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-2 / SCRUM-11 — Connexion & Synchronisation
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * Appelé après chaque login Keycloak depuis Flutter.
     * Crée le profil local au premier login, sinon retourne l'existant.
     */
    public UserDTO createOrUpdateUser(String keycloakId, String email, String role) {
        return userRepository.findByKeycloakId(keycloakId)
            .map(existing -> {
                if (!existing.getEmail().equals(email)) {
                    existing.setEmail(email);
                    userRepository.save(existing);
                }
                log.debug("Sync utilisateur existant: {}", keycloakId);
                return UserDTO.from(existing);
            })
            .orElseGet(() -> {
                log.info("Création nouveau profil pour: {} role={}", email, role);
                User user = User.builder()
                    .keycloakId(keycloakId)
                    .email(email)
                    .role(Role.valueOf(role))
                    .build();
                return UserDTO.from(userRepository.save(user));
            });
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  INSCRIPTION — Création compte Keycloak depuis le backend
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * Crée un utilisateur dans Keycloak via l'API Admin,
     * puis lui assigne le rôle choisi (PATIENT ou PHARMACIEN).
     * Appelé depuis POST /api/users/register (endpoint public).
     */
    public void registerUser(RegisterRequest req) {
        try {
            String adminToken = getAdminToken();
            String userId     = createKeycloakUser(adminToken, req);
            assignRole(adminToken, userId, req.getRole());
            log.info("Utilisateur inscrit avec succès: {} role={}", req.getEmail(), req.getRole());
        } catch (HttpClientErrorException e) {
            log.error("Keycloak error [{}]: {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new RuntimeException("KEYCLOAK_" + e.getStatusCode().value() + ": " + e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("Erreur inscription: {}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
    }

    // ── Obtenir le token admin depuis le realm master ────────────────────
    private String getAdminToken() {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("grant_type", "password");
        body.add("client_id",  "admin-cli");
        body.add("username",   "mariem");
        body.add("password",   "mariem123"); // ← mot de passe admin Keycloak

        ResponseEntity<Map> resp = rt.exchange(
            "http://localhost:8080/realms/master/protocol/openid-connect/token",
            HttpMethod.POST,
            new HttpEntity<>(body, headers),
            Map.class
        );

        return (String) Objects.requireNonNull(resp.getBody()).get("access_token");
    }

    // ── Créer l'utilisateur dans Keycloak ────────────────────────────────
    // Retourne le userId Keycloak (extrait du header Location de la réponse)
    private String createKeycloakUser(String adminToken, RegisterRequest req) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(adminToken);

        Map<String, Object> user = new HashMap<>();
        user.put("username",      req.getEmail());
        user.put("email",         req.getEmail());
        user.put("firstName",     req.getFirstName());
        user.put("lastName",      req.getLastName());
        user.put("enabled",       true);
        user.put("emailVerified", true);
        user.put("credentials",   List.of(Map.of(
            "type",      "password",
            "value",     req.getPassword(),
            "temporary", false
        )));
        user.put("attributes", Map.of(
            "phoneNumber", List.of(req.getPhoneNumber() != null ? req.getPhoneNumber() : ""),
            "address",     List.of(req.getAddress()     != null ? req.getAddress()     : "")
        ));

        ResponseEntity<Void> resp = rt.exchange(
            "http://localhost:8080/admin/realms/pharma-app/users",
            HttpMethod.POST,
            new HttpEntity<>(user, headers),
            Void.class
        );

        String location = resp.getHeaders().getFirst("Location");
        if (location == null) throw new RuntimeException("Location header manquant");
        return location.substring(location.lastIndexOf("/") + 1);
    }

    // ── Assigner le rôle realm à l'utilisateur ──────────────────────────
    private void assignRole(String adminToken, String userId, String roleName) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);

        // 1. Récupérer la représentation du rôle
        ResponseEntity<Map> roleResp = rt.exchange(
            "http://localhost:8080/admin/realms/pharma-app/roles/" + roleName,
            HttpMethod.GET,
            new HttpEntity<>(headers),
            Map.class
        );

        // 2. Assigner le rôle
        headers.setContentType(MediaType.APPLICATION_JSON);
        rt.exchange(
            "http://localhost:8080/admin/realms/pharma-app/users/" + userId + "/role-mappings/realm",
            HttpMethod.POST,
            new HttpEntity<>(List.of(roleResp.getBody()), headers),
            Void.class
        );
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-10 — Gérer mon profil
    // ═══════════════════════════════════════════════════════════════════════

    @Transactional(readOnly = true)
    public UserDTO getCurrentUser(Authentication auth) {
        return userRepository.findByKeycloakId(auth.getName())
            .map(UserDTO::from)
            .orElseThrow(() -> new EntityNotFoundException("Profil non trouvé. Veuillez vous reconnecter."));
    }

    public UserDTO updateProfile(UpdateProfileRequest req, Authentication auth) {
        User user = getByAuth(auth);
        if (req.getFirstName()   != null) user.setFirstName(req.getFirstName());
        if (req.getLastName()    != null) user.setLastName(req.getLastName());
        if (req.getPhoneNumber() != null) user.setPhoneNumber(req.getPhoneNumber());
        if (req.getDateOfBirth() != null) user.setDateOfBirth(req.getDateOfBirth());
        log.info("Profil mis à jour pour: {}", auth.getName());
        return UserDTO.from(userRepository.save(user));
    }

    public void updateFcmToken(String fcmToken, Authentication auth) {
        User user = getByAuth(auth);
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-2 — Profil médical : Allergies
    // ═══════════════════════════════════════════════════════════════════════

    @Transactional(readOnly = true)
    public List<AllergyDTO> getAllergies(Authentication auth) {
        User user = getByAuth(auth);
        return allergyRepository.findByUserId(user.getId())
            .stream()
            .map(AllergyDTO::from)
            .collect(Collectors.toList());
    }

    public AllergyDTO addAllergy(AllergyDTO.Request req, Authentication auth) {
        User user = getByAuth(auth);
        Allergy allergy = Allergy.builder()
            .user(user)
            .substanceName(req.getSubstanceName())
            .severity(req.getSeverity() != null ? req.getSeverity() : "MILD")
            .description(req.getDescription())
            .build();
        log.info("Allergie ajoutée: {} pour user: {}", req.getSubstanceName(), auth.getName());
        return AllergyDTO.from(allergyRepository.save(allergy));
    }

    public void removeAllergy(UUID allergyId, Authentication auth) {
        User user = getByAuth(auth);
        Allergy allergy = allergyRepository.findById(allergyId)
            .orElseThrow(() -> new EntityNotFoundException("Allergie introuvable: " + allergyId));
        if (!allergy.getUser().getId().equals(user.getId())) {
            throw new SecurityException("Accès refusé : cette allergie n'appartient pas à cet utilisateur");
        }
        allergyRepository.delete(allergy);
        log.info("Allergie supprimée: {} par user: {}", allergyId, auth.getName());
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  SCRUM-17 — Gérer comptes pharmaciens (Admin)
    // ═══════════════════════════════════════════════════════════════════════

    @Transactional(readOnly = true)
    public List<UserDTO> getAllPharmaciens() {
        return userRepository.findByRole(Role.PHARMACIEN)
            .stream()
            .map(UserDTO::from)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<UserDTO> getAllPatients() {
        return userRepository.findByRole(Role.PATIENT)
            .stream()
            .map(UserDTO::from)
            .collect(Collectors.toList());
    }

    public void deleteUser(UUID userId) {
        if (!userRepository.existsById(userId)) {
            throw new EntityNotFoundException("Utilisateur introuvable: " + userId);
        }
        userRepository.deleteById(userId);
        log.info("Utilisateur supprimé: {}", userId);
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ENDPOINTS INTERNES (inter-services — sans gateway)
    // ═══════════════════════════════════════════════════════════════════════

    @Transactional(readOnly = true)
    public Optional<UserDTO> getInternalUser(String keycloakId) {
        return userRepository.findByKeycloakId(keycloakId).map(UserDTO::from);
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  HELPER
    // ═══════════════════════════════════════════════════════════════════════

    public User getByAuth(Authentication auth) {
        return userRepository.findByKeycloakId(auth.getName())
            .orElseThrow(() -> new EntityNotFoundException(
                "Utilisateur non trouvé pour keycloakId: " + auth.getName()));
    }
}