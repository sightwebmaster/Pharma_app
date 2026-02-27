package com.pharma.repository;

import com.pharma.entity.Role;
import com.pharma.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByKeycloakId(String keycloakId);

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    /** Pour Sprint 1 — SCRUM-17 : lister les pharmaciens (admin) */
    List<User> findByRole(Role role);
}
