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

import javax.servlet.http.HttpSession;

@RestController
@RequestMapping("/spotify")
@CrossOrigin
public class SpotifyController {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${spotify.client.secret}")
    private String clientSecret;
    
    private final String clientId = "63fceae31a674af69bad8fa2d1e5bf47";
    
    private final String redirectUri = "https://pinoken.onrender.com/";

    @PostMapping("/getMusic")
    public ResponseEntity<Map<String, Object>> handleCallback(@RequestBody Map<String, String> request, HttpSession session) {
        String code = request.get("code");

        // ① アクセストークン取得
        // セッションにアクセストークンなければ認可コードから取得
        if (session.getAttribute("access_token") == null) {
            String tokenEndpoint = "https://accounts.spotify.com/api/token";

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

            session.setAttribute("access_token", tokenResponse.getBody().get("access_token"));
            session.setAttribute("refresh_token", tokenResponse.getBody().get("refresh_token"));
        }

        String accessToken = (String) session.getAttribute("access_token");
        String refreshToken = (String) session.getAttribute("refresh_token");


        // ② 曲を取得（現在再生中 → 最近再生した曲）
        HttpHeaders apiHeaders = new HttpHeaders();
        apiHeaders.set("Authorization", "Bearer " + accessToken);
        HttpEntity<Void> apiRequest = new HttpEntity<>(apiHeaders);

        String nowPlayingUrl = "https://api.spotify.com/v1/me/player/currently-playing";
        ResponseEntity<Map> nowPlayingRes = restTemplate.exchange(nowPlayingUrl, HttpMethod.GET, apiRequest, Map.class);

        // 401だったらアクセストークンが無効なのでリフレッシュする
        if (nowPlayingRes.getStatusCode() == HttpStatus.UNAUTHORIZED && refreshToken != null) {
            accessToken = refreshAccessToken(refreshToken);
            session.setAttribute("access_token", accessToken); // セッションに保存

            // 新しいトークンでリトライ
            apiHeaders.set("Authorization", "Bearer " + accessToken);
            apiRequest = new HttpEntity<>(apiHeaders);
            nowPlayingRes = restTemplate.exchange(nowPlayingUrl, HttpMethod.GET, apiRequest, Map.class);
        }

        Map<String, String> trackInfo = null;

        if (nowPlayingRes.getStatusCode().is2xxSuccessful() && nowPlayingRes.getBody() != null && nowPlayingRes.getBody().get("item") != null) {
            Map item = (Map) nowPlayingRes.getBody().get("item");
            trackInfo = getTrackInfo(item);
        } else {
            String recentUrl = "https://api.spotify.com/v1/me/player/recently-played?limit=1";
            ResponseEntity<Map> recentRes = restTemplate.exchange(recentUrl, HttpMethod.GET, apiRequest, Map.class);
            if (recentRes.getStatusCode().is2xxSuccessful() && recentRes.getBody() != null) {
                List<Map> items = (List<Map>) recentRes.getBody().get("items");
                if (!items.isEmpty()) {
                    Map track = (Map) ((Map) items.get(0).get("track"));
                    trackInfo = getTrackInfo(track);
                }
            }
        }

        

        if (trackInfo != null) {
            return ResponseEntity.ok(Map.of(
                "success", true,
                "track", trackInfo.get("track"),
                "url", trackInfo.get("url")
            ));
        } else {
            return ResponseEntity.ok(Map.of("success", false, "error", "曲情報が取得できませんでした"));
        }

    }

    private Map<String, String> getTrackInfo(Map trackData) {
        String name = (String) trackData.get("name");
        List<Map> artists = (List<Map>) trackData.get("artists");
        String artistName = (String) artists.get(0).get("name");

        Map<String, String> externalUrls = (Map<String, String>) trackData.get("external_urls");
        String url = externalUrls.get("spotify");

        Map<String, String> result = new HashMap<>();
        result.put("track", name + " - " + artistName);
        result.put("url", url);

        return result;
    }

    private String refreshAccessToken(String refreshToken) {

        HttpHeaders headers = new HttpHeaders();
        String credentials = clientId + ":" + clientSecret;
        String encodedCredentials = Base64Utils.encodeToString(credentials.getBytes(StandardCharsets.UTF_8));
        headers.set("Authorization", "Basic " + encodedCredentials);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "refresh_token");
        params.add("refresh_token", refreshToken);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);
        ResponseEntity<Map> response = restTemplate.exchange(
            "https://accounts.spotify.com/api/token", HttpMethod.POST, request, Map.class
        );

        if (response.getStatusCode().is2xxSuccessful()) {
            return (String) response.getBody().get("access_token");
        }
        return null;
    }
}
