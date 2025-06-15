package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
public class APIController {
    @GetMapping("/get/JWTToken")
    public Map<String, String> getJWTToken() {
        String token = getJWTTokenFromAws(); 
        return Map.of("token", token); 
    }

    private String getJWTTokenFromAws() {
        try {
            URL url = new URL("https://llgctsrfu5.execute-api.ap-southeast-2.amazonaws.com/generate_JWT_token");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String response = reader.lines().collect(Collectors.joining());
                return response.replace("{\"token\":\"", "").replace("\"}", "");
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}