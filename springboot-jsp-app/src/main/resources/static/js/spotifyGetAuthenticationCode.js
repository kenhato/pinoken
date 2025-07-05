// 認可コード取得用関数
function setSpotifyAuthenticationParameter(clientId, redirectUri, scope) {

    const encodedRedirectUri = encodeURIComponent(redirectUri);
    const encodedScope = encodeURIComponent(scope);
    const state = "state_" + Math.random().toString(36).substring(7); // ランダムなstate

    const authUrl = `https://accounts.spotify.com/authorize` +
        `?client_id=${clientId}` +
        `&response_type=code` +
        `&redirect_uri=${encodedRedirectUri}` +
        `&scope=${encodedScope}` +
        `&state=${state}`;

    window.location.href = authUrl;

}

// 認可コード取得
function tweetNowPlayingSpotify() {

    const clientId = "63fceae31a674af69bad8fa2d1e5bf47";
    const redirectUri = "https://pinoken.onrender.com/";
    const scope = "user-read-recently-played%20user-read-currently-playing%20user-read-playback-state";

    setSpotifyAuthenticationParameter(clientId, redirectUri, scope);
}

// 認可コード取得後、再生中or直近再生した曲の取得
function handleSpotifyRedirect() {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    if (code) {
        fetch("/spotify/getMusic", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ code: code })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success && data.track) {
                // ツイートへ遷移
                const tweetText = `${data.track} #NowPlaying`;
                const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetText)}`;
                window.location.href = twitterUrl;
            } else {
                alert("曲が取得できませんでした。");
            }
        })
        .catch(err => {
            console.error("エラー:", err);
        });
    }
}