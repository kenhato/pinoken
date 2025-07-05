<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <script src="/js/spotifyGetAuthenticationCode.js"></script>
    <link rel="stylesheet" href="styles.css">
    <title>Spotify Callback</title>
</head>
<body>
<p>Spotify認証中…</p>

<script>
window.onload = () => {
    handleSpotifyRedirect(); // リダイレクト後にSpotify認可コード読み取り
};
</script>

</body>
</html>
