package com.pharma.dto;

import com.pharma.entity.Allergy;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class AllergyDTO {

    private UUID id;
    private String substanceName;
    private String severity;
    private String description;

    public static AllergyDTO from(Allergy a) {
        return AllergyDTO.builder()
            .id(a.getId())
            .substanceName(a.getSubstanceName())
            .severity(a.getSeverity())
            .description(a.getDescription())
            .build();
    }

    /** Corps de la requête POST /me/allergies */
    @Data
    public static class Request {
        @NotBlank(message = "Le nom de la substance est requis")
        private String substanceName;

        private String severity = "MILD"; // MILD | MODERATE | SEVERE

        private String description;
    }
}
