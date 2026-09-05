package com.investmenttracker.model.enums;

import lombok.Getter;

@Getter
public enum Plan {
    FREE("ROLE_USER"),
    PREMIUM("ROLE_PREMIUM");

    private final String roleName;

    Plan(String roleName) {
        this.roleName = roleName;
    }
}
