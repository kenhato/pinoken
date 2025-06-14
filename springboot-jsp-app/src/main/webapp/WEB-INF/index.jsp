<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ツイート生成ページ</title>

    <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-HJRPPJ3SW1"></script>
    <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'G-HJRPPJ3SW1');
    </script>

    <link rel="stylesheet" href="styles.css">
    <script src="https://js-cdn.music.apple.com/musickit/v3/musickit.js"></script>
</head>
<body>
    <div class="container">
        <div class="sparkle-background" id="sparkleEffect"></div>
        <h1>ツイート生成ページ</h1>

        <p>休憩ツイート</p>
        <button id="shuffleButton1" class="button break"><span class="emoji">☕</span>休憩を報告する</button>
        <button id="shuffleButton2" class="button lunch"><span class="emoji">🌤️</span>お昼休憩を報告する</button>
        <button id="shuffleButton3" class="button night"><span class="emoji">🌙</span>夜休憩を報告する</button>

        <p>腹痛ツイート</p>
        <button id="painLevelButton" class="button stomach"><span class="emoji">🚽</span>腹痛を報告する</button>

        <p>なうぷれ（Apple Music専用）</p>
        <div id="nowPlayingCard" class="nowplaying-card hidden">
            <div class="nowplaying-content">
                <img id="albumImage" src="" alt="Album Art">
                <div class="nowplaying-text">
                    <p>聴いてる曲：</p>
                    <strong id="songTitle">タイトル</strong><br>
                    <span id="artistName">アーティスト</span>
                </div>
            </div>
        </div>
        <button id="nowPlayingButton" class="button nowplaying"><span class="emoji">🎵</span>再生中の曲をツイート</button>

        <p>開発者への物申し</p>
        <button class="button night" onclick="window.location.href='comment.html'">開発者に物申す</button>
    </div>

    <div class="footer">
        &copy; 2024 pinoken_
    </div>

    <dialog id="painLevelDialog">
        <form method="dialog">
            <label for="painLevelSelect">腹痛のレベルは？？</label>
            <select id="painLevelSelect">
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
            </select>
            <button type="button" id="tweetPainButton">ツイートする</button>
            <button type="button" id="cancelPainButton">キャンセル</button>
        </form>
    </dialog>

    <!-- 埋め込んだスクリプト -->
    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            document.getElementById('shuffleButton1').addEventListener('click', () => {
                handleClickWithPopup(() => shuffleAndTweet('休憩なう'));
            });
            document.getElementById('shuffleButton2').addEventListener('click', () => {
                handleClickWithPopup(() => shuffleAndTweet('お昼休憩なう'));
            });
            document.getElementById('shuffleButton3').addEventListener('click', () => {
                handleClickWithPopup(() => shuffleAndTweet('夜休憩なう'));
            });
            document.getElementById('painLevelButton').addEventListener('click', () => {
                handleClickWithPopup(showPainLevelDialog);
            });
            document.getElementById('nowPlayingButton').addEventListener('click', () => {
                handleClickWithPopup(tweetNowPlaying);
            });
            document.getElementById('tweetPainButton').addEventListener('click', tweetPainReport);
            document.getElementById('cancelPainButton').addEventListener('click', () => {
                document.getElementById('painLevelDialog').close();
            });

            await initMusicKitWithCache();
        });

        const TOKEN_KEY = "appleDevToken";
        const EXPIRY_KEY = "appleDevTokenExpiry";
        const THREE_MONTHS_MS = 90 * 24 * 60 * 60 * 1000;

        async function initMusicKitWithCache() {
            try {
                let token = localStorage.getItem(TOKEN_KEY);
                const expiry = Number(localStorage.getItem(EXPIRY_KEY));
                const now = Date.now();

                if (!token || !expiry || now > expiry) {
                    const res = await fetch("https://llgctsrfu5.execute-api.ap-southeast-2.amazonaws.com/generate_JWT_token");
                    const data = await res.json();
                    token = data.token;
                    localStorage.setItem(TOKEN_KEY, token);
                    localStorage.setItem(EXPIRY_KEY, (now + THREE_MONTHS_MS).toString());
                }

                await MusicKit.configure({
                    developerToken: token,
                    app: { name: "TweetGenerator", build: "1.0.0" }
                });

                await ShowRecentSong();
            } catch (error) {
                console.error("MusicKit初期化中にエラー:", error);
            }
        }

        function handleClickWithPopup(callback) {
            const randomValue = Math.random();
            const popupChance = 0.05;
            if (randomValue < popupChance) {
                alert("使ってくれてありがとう！");
            }
            callback();
        }

        function shuffleAndTweet(originalString) {
            const array = originalString.split('');
            for (let i = array.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [array[i], array[j]] = [array[j], array[i]];
            }
            const shuffledString = array.join('');
            const tweetContent = `${shuffledString} #休憩なう`;
            window.location.href = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetContent)}`;
        }

        function showPainLevelDialog() {
            document.getElementById("painLevelDialog").showModal();
        }

        function tweetPainReport() {
            const painLevel = document.getElementById("painLevelSelect").value;
            const tweetContent = `腹痛レベル：${painLevel}\n#ピノキオピー腹痛サークル`;
            window.location.href = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetContent)}`;
            document.getElementById("painLevelDialog").close();
        }

        async function fetchNowPlayingSong() {
            const music = MusicKit.getInstance();
            const developerToken = music.developerToken;

            const fetchTrack = async () => {
                const token = music.musicUserToken;
                const response = await fetch("https://api.music.apple.com/v1/me/recent/played/tracks?limit=1", {
                    method: "GET",
                    headers: {
                        "Authorization": `Bearer ${developerToken}`,
                        "Music-User-Token": token,
                        "Cache-Control": "no-cache"
                    }
                });
                if (!response.ok) throw new Error(`APIエラー: ${response.status}`);
                const data = await response.json();
                const nowPlaying = data.data?.[0]?.attributes;
                return nowPlaying ? {
                    title: nowPlaying.name || "Unknown Title",
                    artist: nowPlaying.artistName || "Unknown Artist",
                    url: nowPlaying.url || "https://music.apple.com/",
                    artworkUrl: nowPlaying.artwork?.url.replace('{w}x{h}', '500x500') || ""
                } : null;
            };

            try {
                return await fetchTrack();
            } catch (error) {
                if (error.message.includes("401") || error.message.includes("403")) {
                    try {
                        await music.unauthorize();
                        await music.authorize();
                        return await fetchTrack();
                    } catch (reauthError) {
                        alert("Apple Music の再認証に失敗しました。");
                        return null;
                    }
                } else {
                    alert("曲情報の取得に失敗しました。");
                    return null;
                }
            }
        }

        async function tweetNowPlaying() {
            const music = MusicKit.getInstance();
            try {
                await music.authorize();
                const nowPlaying = await fetchNowPlayingSong();
                if (!nowPlaying) return alert("現在再生中の曲がありません！");
                const fixedUrl = nowPlaying.url.replace("?i=", "?&i=");
                const tweetContent = `#NowPlaying ${nowPlaying.title} - ${nowPlaying.artist}\n${fixedUrl}`;
                window.location.href = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetContent)}`;
            } catch (err) {
                alert("Apple Music の認証またはデータ取得に失敗しました。");
            }
        }

        const SPECIAL_SONG = "はっぴーべりーはっぴー";
        const SPECIAL_ARTIST = "ピノキオピー";

        async function ShowRecentSong() {
            const music = MusicKit.getInstance();
            try {
                if (!music.isAuthorized) return;
                await music.authorize();
                const nowPlaying = await fetchNowPlayingSong();
                if (nowPlaying) {
                    if (nowPlaying.title.includes(SPECIAL_SONG) && nowPlaying.artist.includes(SPECIAL_ARTIST)) {
                        document.body.classList.add("happyberry-mode");
                        document.getElementById("sparkleEffect").style.display = "block";
                    }
                    document.getElementById("albumImage").src = nowPlaying.artworkUrl;
                    document.getElementById("songTitle").textContent = nowPlaying.title;
                    document.getElementById("artistName").textContent = nowPlaying.artist;
                    document.getElementById("nowPlayingCard").classList.remove("hidden");
                }
            } catch (err) {
                console.warn("再生中の曲取得スキップ：", err);
            }
        }
    </script>
</body>
</html>
