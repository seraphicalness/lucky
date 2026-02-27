package com.harugiwun;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class HarugiwunServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(HarugiwunServerApplication.class, args);
    }
}
