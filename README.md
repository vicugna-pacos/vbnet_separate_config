App.configの内容をターゲット毎に切り替えるサンプル(VB.NET版)

Windowsフォーム等で、App.configをDebug/Release毎に変えられるようにしたもの。  
ASP.NET方式はなぜかVB.NETでは有効ではなかった＆Settingsには使えないということで、
ビルド後にPowerShellでconfigファイル内の値を書き換えるようにした。

[Windows Form(VB.NET)で設定値をDebugとReleaseで切り替えたい - Qiita](https://qiita.com/vicugna-pacos/items/e63b0c7f1edbf3f6cb72)
参照。
