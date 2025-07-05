// 確率でポップアップ出現
function handleClickWithPopup(callback) {
    const randomValue = Math.random();
    const popupChance = 0.05; // ポップアップ表示
    if (randomValue < popupChance) {
        alert("使ってくれてありがとう！");
    }
    callback();
}