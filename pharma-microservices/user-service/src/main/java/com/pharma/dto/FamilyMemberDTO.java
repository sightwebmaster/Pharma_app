package com.pharma.dto;

import com.pharma.entity.FamilyMember;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
public class FamilyMemberDTO {

    private UUID   id;
    private String firstName;
    private String lastName;
    private String relation;
    private LocalDate dateOfBirth;

    public static FamilyMemberDTO from(FamilyMember fm) {
        return FamilyMemberDTO.builder()
            .id(fm.getId())
            .firstName(fm.getFirstName())
            .lastName(fm.getLastName())
            .relation(fm.getRelation())
            .dateOfBirth(fm.getDateOfBirth())
            .build();
    }

    // ── Requête pour ajouter un proche ──────────────────────────────────────
    @Data
    public static class Request {
        @NotBlank
        private String firstName;
        private String lastName;
        /** CHILD | PARENT | SPOUSE | SIBLING | OTHER */
        private String relation;
        private LocalDate dateOfBirth;
    }
}