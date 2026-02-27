package com.pharma.dto;

import lombok.Data;

/** Réponse de /api/users/sync */
@Data
public class SyncRequest {
    private String keycloakId;
    private String email;
    private String role;
}
