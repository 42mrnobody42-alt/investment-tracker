package com.investmenttracker.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

import lombok.Getter;

@Configuration
@PropertySource("classpath:.unitTestEnv")
@Getter
public class TestConfig {

    @Value("${TEST_USER_DEMO}")
    private String demoUser;

    @Value("${TEST_USER_DEMO_EMAIL}")
    private String demoEmail;

    @Value("${TEST_USER_DEMO_PASSWORD}")
    private String demoPassword;

    @Value("${TEST_USER_DEMO_NOMBRE}")
    private String demoNombre;

    @Value("${TEST_USER_DEMO_NEW_PASSWORD}")
    private String demoNewPassword;

    @Value("${TEST_USER_ADMIN}")
    private String adminUser;

    @Value("${TEST_USER_ADMIN_EMAIL}")
    private String adminEmail;

    @Value("${TEST_USER_ADMIN_PASSWORD}")
    private String adminPassword;

    @Value("${TEST_USER_ADMIN_NOMBRE}")
    private String adminNombre;

    @Value("${TEST_USER_INCOGNITO}")
    private String incognitoUser;

    @Value("${TEST_USER_INCOGNITO_EMAIL}")
    private String incognitoEmail;

    @Value("${TEST_USER_INCOGNITO_PASSWORD}")
    private String incognitoPassword;

    @Value("${TEST_USER_INCOGNITO_NOMBRE}")
    private String incognitoNombre;

    @Value("${TEST_USER_INCOGNITO_NEW_PASSWORD}")
    private String incognitoNewPassword;

    @Value("${TEST_REGISTER_USERNAME_FREE}")
    private String registerUsernameFree;

    @Value("${TEST_REGISTER_USERNAME_PREMIUM}")
    private String registerUsernamePremium;

    @Value("${TEST_REGISTER_EMAIL_FREE}")
    private String registerEmailFree;

    @Value("${TEST_REGISTER_EMAIL_PREMIUM}")
    private String registerEmailPremium;

    @Value("${TEST_REGISTER_NOMBRE}")
    private String registerNombre;

    @Value("${TEST_REGISTER_PASSWORD}")
    private String registerPassword;

    @Value("${TEST_REGISTER_CELULAR}")
    private Long registerCelular;

    @Value("${TEST_REGISTER_PAIS_ID}")
    private String registerPaisId;

    @Value("${TEST_BASE_URL}")
    private String baseUrl;
}
