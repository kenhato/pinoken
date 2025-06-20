package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.json.JSONObject; 

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
public class APIController {

   @Value("${jwt.api.url}")
    private String jwtApiUrl;

    @Value("${jwt.api.key}")
    private String jwtApiKey;

    @GetMapping("/get/JWTToken")
    public Map<String, String> getJWTToken() {
        String token = getJWTTokenFromAws(); 
        return Map.of("token", token); 
    }

    private String getJWTTokenFromAws() {
        try {
            URL url = new URL(jwtApiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("x-api-key", jwtApiKey);

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String response = reader.lines().collect(Collectors.joining());

                // Lambdaからのレスポンスが { "statusCode": 200, ..., "body": "{\"token\":\"xxx\"}" } の場合
                JSONObject outer = new JSONObject(response);
                JSONObject inner = new JSONObject(outer.getString("body"));

                return inner.getString("token");
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}