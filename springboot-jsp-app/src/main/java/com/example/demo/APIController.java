package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class APIController {

    @Value("${jwt.token}")
    private String jwtToken;

    @GetMapping("/get/JWTToken")
    public Map<String, String> getJWTToken() {
        return Map.of("token", jwtToken);
    }
}
