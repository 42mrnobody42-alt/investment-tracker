package com.investmenttracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class InvestmentTrackerApplication {

    public static void main(String[] args) {
        SpringApplication.run(InvestmentTrackerApplication.class, args);
    }
}
