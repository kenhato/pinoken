<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ja">

<script>
const TOKEN_KEY = "appleDevToken";
let music; 

// MusicKit初期化関数
async function initMusicKitWithCache(){
try{
    const res = await fetch("/get/JWTToken");
    const data = await res.json();
    const token = data.token; 

    console.log("🎶 MusicKit初期化中…");
    await MusicKit.configure({
        developerToken: token,
        app: {
        name: "TweetGenerator",
        build: "1.0.0"
        }
    });
    console.log("✅ MusicKit初期化成功！");

     music = MusicKit.getInstance(); // グローバル変数に格納！！

    await ShowRecentSong();

} catch (error) {
    console.error("MusicKit初期化中にエラー:", error);
}}

// 確率でポップアップ出現
function handleClickWithPopup(callback) {
    const randomValue = Math.random();
    const popupChance = 0.05; // ポップアップ表示
    if (randomValue < popupChance) {
        alert("使ってくれてありがとう！");
    }
    callback();
}

// 文字をシャッフルしてツイート
function shuffleAndTweet(originalString) {
    const array = originalString.split('');
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    const shuffledString = array.join('');
    const tweetContent = `\${shuffledString} #休憩なう`;

    const tweetUrlWeb = `https://twitter.com/intent/tweet?text=\${encodeURIComponent(tweetContent)}`;
    window.location.href = tweetUrlWeb;
}

// 腹痛ツイート関連
function showPainLevelDialog() {
    const dialog = document.getElementById("painLevelDialog");
    dialog.showModal();
}

function tweetPainReport() {
    const painLevel = document.getElementById("painLevelSelect").value;
    const tweetContent = `腹痛レベル：\${painLevel}\n#ピノキオピー腹痛サークル`;

    const tweetUrlWeb = `https://twitter.com/intent/tweet?text=\${encodeURIComponent(tweetContent)}`;
    window.location.href = tweetUrlWeb;

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
            "Authorization": `Bearer \${developerToken}`,
            "Music-User-Token": token,
            "Cache-Control": "no-cache"
        }
    });

    if (!response.ok) {
        throw new Error(`APIエラー: \${response.status}`);
    }

    const data = await response.json();
    const nowPlaying = data.data?.[0]?.attributes;
    if (!nowPlaying) return null;

    return {
        title: nowPlaying.name || "Unknown Title",
        artist: nowPlaying.artistName || "Unknown Artist",
        url: nowPlaying.url || "https://music.apple.com/",
        artworkUrl: nowPlaying.artwork?.url.replace('{w}x{h}', '500x500') || ""
    };  
};

try {
    return await fetchTrack();
    } catch (error) {
        console.warn("初回トークンで失敗:", error.message);

        if (error.message.includes("401") || error.message.includes("403")) {
            try {
                await music.unauthorize();
                await music.authorize(); // トークンは自動で music.musicUserToken にセットされる
                console.log("再認証成功、トークン再取得");
                return await fetchTrack();
            } catch (reauthError) {
                console.error("再認証失敗:", reauthError);
                alert("Apple Music の再認証に失敗しました。");
                return null;
            }
        } else {
            console.error("その他のエラー:", error);
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

        if (!nowPlaying) {
            alert("現在再生中の曲がありません！");
            return;
        }

        const fixedUrl = nowPlaying.url.replace("?i=", "?&i=");
        const tweetContent = `#NowPlaying \${nowPlaying.title} - \${nowPlaying.artist}\n\${fixedUrl}`;
        const tweetUrlWeb = `https://twitter.com/intent/tweet?text=\${encodeURIComponent(tweetContent)}`;

        console.log("ツイート内容:", tweetContent);
        window.location.href = tweetUrlWeb;
    } catch (err) {
        console.error("認証エラーまたは曲情報取得エラー:", err);
        alert("Apple Music の認証またはデータ取得に失敗しました。");
    }
}

// 曲表示関数
const SPECIAL_SONG = "はっぴーべりーはっぴー";
const SPECIAL_ARTIST = "ピノキオピー";

async function ShowRecentSong() {

  try {
    if (!music.isAuthorized) return;

    const token = await music.authorize();

    const nowPlaying = await fetchNowPlayingSong(token);
    if (nowPlaying) {

      if (nowPlaying.title.includes(SPECIAL_SONG) && nowPlaying.artist.includes(SPECIAL_ARTIST)) {
        document.body.classList.add("happyberry-mode");
        document.getElementById("sparkleEffect").style.display = "block";
      }

      document.getElementById("albumImage").src = nowPlaying.artworkUrl;
      document.getElementById("songTitle").textContent = nowPlaying.title;
      document.getElementById("artistName").textContent = nowPlaying.artist;
      document.getElementById("nowPlayingCard").classList.remove("hidden");
      document.getElementById("tweetNowPlaying").onclick = () => {
        const tweetContent = `#NowPlaying \${nowPlaying.title} - \${nowPlaying.artist}\n\${nowPlaying.url}`;
        window.location.href = `https://twitter.com/intent/tweet?text=\${encodeURIComponent(tweetContent)}`;
      };
      document.getElementById("nowPlayingCard").classList.remove("hidden");
    }
  } catch (err) {
    console.warn("再生中の曲取得スキップ：", err);
  }
}

</script>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ツイート生成ページ</title>

    <script async src="https://www.googletagmanager.com/gtag/js?id=G-HJRPPJ3SW1"></script>
    <script>
        window.dataLayer = window.dataLayer || [];
        function gtag() { dataLayer.push(arguments); }
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

        <!-- シャッフルツイート -->
        <p>休憩ツイート</p>
        <button id="shuffleButton1" class="button break"><span class="emoji">☕</span>休憩を報告する</button>
        <button id="shuffleButton2" class="button lunch"><span class="emoji">🌤️</span>お昼休憩を報告する</button>
        <button id="shuffleButton3" class="button night"><span class="emoji">🌙</span>夜休憩を報告する</button>

        <!-- 腹痛ツイート -->
        <p>腹痛ツイート</p>
        <button id="painLevelButton" class="button stomach"><span class="emoji">🚽</span>腹痛を報告する</button>

        <!-- なうぷれ（Apple Music専用） -->
        <p>なうぷれ（Apple Music専用）</p>
        <!-- なうぷれ表示ブロック -->
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

    </div>

    <div class="footer">
        &copy; 2024 pinoken_
    </div>

    <!-- 腹痛報告用ダイアログ -->
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

    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            // ボタンイベント登録
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

        });
    </script>

</body>

</html>