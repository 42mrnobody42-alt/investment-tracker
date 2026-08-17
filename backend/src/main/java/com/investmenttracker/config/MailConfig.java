package com.investmenttracker.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Objects;
import java.util.Properties;

@Configuration
public class MailConfig {

    @Value("${smtp.host}")
    private String host;

    @Value("${smtp.port}")
    private int port;

    @Value("${smtp.username}")
    private String username;

    @Value("${smtp.password}")
    private String password;

    @Value("${smtp.auth}")
    private boolean auth;

    @Value("${smtp.starttls.enable}")
    private boolean starttlsEnable;

    @Bean
    public JavaMailSender javaMailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(Objects.requireNonNull(host, "SMTP host no puede ser null"));
        mailSender.setPort(port);
        mailSender.setUsername(Objects.requireNonNull(username, "SMTP username no puede ser null"));
        mailSender.setPassword(Objects.requireNonNull(password, "SMTP password no puede ser null"));

        Properties props = mailSender.getJavaMailProperties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.auth", String.valueOf(auth));
        props.put("mail.smtp.starttls.enable", String.valueOf(starttlsEnable));
        props.put("mail.smtp.starttls.required", String.valueOf(starttlsEnable));
        props.put("mail.debug", "false");

        return mailSender;
    }
}
