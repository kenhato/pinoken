let music; // グローバル変数

// MusicKit初期化関数
async function initMusicKitWithCache() {
  if (music) return music; // 初期化済みなら再利用

  try {
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

    music = MusicKit.getInstance(); // グローバル変数に格納
    console.log("✅ MusicKit初期化成功！");
    return music;

  } catch (error) {
    console.error("MusicKit初期化中にエラー:", error);
  }
}

async function fetchNowPlayingSong() {
  await initMusicKitWithCache();

  const fetchTrack = async () => {
    const token = music.musicUserToken;
    const response = await fetch("https://api.music.apple.com/v1/me/recent/played/tracks?limit=1", {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${music.developerToken}`,
        "Music-User-Token": token,
        "Cache-Control": "no-cache"
      }
    });

    if (!response.ok) {
      throw new Error(`APIエラー: ${response.status}`);
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
        await music.authorize();
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
  await initMusicKitWithCache();

  try {
    await music.authorize();

    const nowPlaying = await fetchNowPlayingSong();
    if (!nowPlaying) {
      alert("現在再生中の曲がありません！");
      return;
    }

    const fixedUrl = nowPlaying.url.replace("?i=", "?&i=");
    const tweetContent = `#NowPlaying ${nowPlaying.title} - ${nowPlaying.artist}\n${fixedUrl}`;
    const tweetUrlWeb = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetContent)}`;

    console.log("ツイート内容:", tweetContent);
    window.location.href = tweetUrlWeb;
  } catch (err) {
    console.error("認証エラーまたは曲情報取得エラー:", err);
    alert("Apple Music の認証またはデータ取得に失敗しました。");
  }
}

const SPECIAL_SONG = "はっぴーべりーはっぴー";
const SPECIAL_ARTIST = "ピノキオピー";

async function ShowRecentSong() {
  await initMusicKitWithCache();

  try {
    if (!music.isAuthorized) await music.authorize();

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

      document.getElementById("tweetNowPlaying").onclick = () => {
        const tweetContent = `#NowPlaying ${nowPlaying.title} - ${nowPlaying.artist}\n${nowPlaying.url}`;
        window.location.href = `https://twitter.com/intent/tweet?text=${encodeURIComponent(tweetContent)}`;
      };
    }
  } catch (err) {
    console.warn("再生中の曲取得スキップ：", err);
  }
}
