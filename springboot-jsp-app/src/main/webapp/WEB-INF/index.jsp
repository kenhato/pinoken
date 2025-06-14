<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

    <link rel="stylesheet" href="/styles.css">
    <script src="https://js-cdn.music.apple.com/musickit/v3/musickit.js"></script>
    <script src="/scripts.js" defer></script>
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
</body>
</html>
