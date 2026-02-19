package com.pharma.dto;

import com.pharma.entity.User;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class UserDTO {

    private UUID id;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private LocalDate dateOfBirth;
    private String role;
    private LocalDateTime createdAt;

    public static UserDTO from(User u) {
        return UserDTO.builder()
            .id(u.getId())
            .email(u.getEmail())
            .firstName(u.getFirstName())
            .lastName(u.getLastName())
            .phoneNumber(u.getPhoneNumber())
            .dateOfBirth(u.getDateOfBirth())
            .role(u.getRole() != null ? u.getRole().name() : null)
            .createdAt(u.getCreatedAt())
            .build();
    }
}
