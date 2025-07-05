package com.example.demo;

import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;

import java.nio.charset.StandardCharsets;
import java.util.*;

import org.springframework.util.Base64Utils;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

@RestController
@RequestMapping("/spotify")
@CrossOrigin
public class SpotifyController {

    @Value("${spotify.client.secret}")
    private String clientSecret;
    
    private final String clientId = "63fceae31a674af69bad8fa2d1e5bf47";
    
    private final String redirectUri = "https://pinoken.onrender.com/";

    @PostMapping("/getMusic")
    public ResponseEntity<Map<String, Object>> handleCallback(@RequestBody Map<String, String> request) {
        String code = request.get("code");

        // ① アクセストークン取得
        String tokenEndpoint = "https://accounts.spotify.com/api/token";
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders tokenHeaders = new HttpHeaders();
        String credentials = clientId + ":" + clientSecret;
        String encodedCredentials = Base64Utils.encodeToString(credentials.getBytes(StandardCharsets.UTF_8));
        tokenHeaders.set("Authorization", "Basic " + encodedCredentials);
        tokenHeaders.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> tokenParams = new LinkedMultiValueMap<>();
        tokenParams.add("grant_type", "authorization_code");
        tokenParams.add("code", code);
        tokenParams.add("redirect_uri", redirectUri);

        HttpEntity<MultiValueMap<String, String>> tokenRequest = new HttpEntity<>(tokenParams, tokenHeaders);

        ResponseEntity<Map> tokenResponse = restTemplate.exchange(tokenEndpoint, HttpMethod.POST, tokenRequest, Map.class);

        if (!tokenResponse.getStatusCode().is2xxSuccessful() || tokenResponse.getBody() == null) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", "トークンの取得に失敗しました"));
        }

        String accessToken = (String) tokenResponse.getBody().get("access_token");

        // ② 曲を取得（現在再生中 → 最近再生した曲）
        HttpHeaders apiHeaders = new HttpHeaders();
        apiHeaders.set("Authorization", "Bearer " + accessToken);
        HttpEntity<Void> apiRequest = new HttpEntity<>(apiHeaders);

        String nowPlayingUrl = "https://api.spotify.com/v1/me/player/currently-playing";
        ResponseEntity<Map> nowPlayingRes = restTemplate.exchange(nowPlayingUrl, HttpMethod.GET, apiRequest, Map.class);

        String trackName = null;

        if (nowPlayingRes.getStatusCode().is2xxSuccessful() && nowPlayingRes.getBody() != null && nowPlayingRes.getBody().get("item") != null) {
            Map item = (Map) nowPlayingRes.getBody().get("item");
            trackName = getTrackInfo(item);
        } else {
            String recentUrl = "https://api.spotify.com/v1/me/player/recently-played?limit=1";
            ResponseEntity<Map> recentRes = restTemplate.exchange(recentUrl, HttpMethod.GET, apiRequest, Map.class);
            if (recentRes.getStatusCode().is2xxSuccessful() && recentRes.getBody() != null) {
                List<Map> items = (List<Map>) recentRes.getBody().get("items");
                if (!items.isEmpty()) {
                    Map track = (Map) ((Map) items.get(0).get("track"));
                    trackName = getTrackInfo(track);
                }
            }
        }

        if (trackName != null) {
            return ResponseEntity.ok(Map.of("success", true, "track", trackName));
        } else {
            return ResponseEntity.ok(Map.of("success", false, "error", "曲情報が取得できませんでした"));
        }
    }

    private String getTrackInfo(Map trackData) {
        String name = (String) trackData.get("name");
        List<Map> artists = (List<Map>) trackData.get("artists");
        String artistName = (String) artists.get(0).get("name");
        return artistName + " - " + name;
    }
}
