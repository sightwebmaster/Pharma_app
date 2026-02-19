package com.pharma.service;

import com.pharma.dto.*;
import com.pharma.entity.*;
import com.pharma.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class UserService {

    private final UserRepository       userRepository;
    private final AllergyRepository    allergyRepository;
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
                // Mettre à jour l'email si changé dans Keycloak
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
