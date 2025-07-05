<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ja">

<script>
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
    <script src="/js/getapplemusic.js"></script>
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