# PowerPuppet
Powershellスクリプトをサービスとして常駐させるためのC#ラッパー 

###使用方法
コンパイルしてできた、PowerPuppet.exeを別名に変え、  
そのexeと同名で拡張子がps1のPowershellスクリプトを記述します。  

基本的にはexeの内容は変えず、アプリケーションによってスクリプトの内容を変更することにより
Windowsのサービスという仕組みの中でUNIXのランスクリプトのような手軽さを実現します。

スクリプトの内容は主に以下のようになると思います

* サービス起動・停止ロジック  
* その他エラーハンドリングロジック  
* サービスインストール情報  

サンプルとして、  
nginx_service.exe  
nginx_service.ps1  
とした場合のps1ファイルを  

samplecfgフォルダに配置しておきました。  

サービスインストールする場合は  

Example: InstallUtil.exe nginx_service.exe  

等としてください。  

（InstallUtil.exeはC:\Windows\Microsoft.NET\Framework～\各種バージョン\  
　配下にあります。）

###動作概略
1.常駐サービス動作時は以下のプロパティ・メソッドがps1上にある場合、  
　サービス起動時に同プロパティを読み取ったり、  
　メソッドが逐次呼び出されます。  
　もし、C#サービスの仕様から不足しているプロパティ・メソッドがある場合は  
　Service1.csに記述があるので改修してください。  
　（System.ServiceProcess.ServiceBaseのプロパティ・メソッドです）  

・プロパティ  
ServiceName  
CanStop  
CanShutdown  
CanPauseAndContinue  
CanHandlePowerEvent  
CanHandleSessionChangeEvent  
AutoLog  
ExitCode  

・メソッド  
OnStart  
OnStop  
OnContinue  
OnCustomCommand  
OnPause  
OnPowerEvent  
OnSessionChange  
OnShutdown  
Dispose  

2.インストーラ動作時  
ps1中のgetServiceProcessInstallerメソッドが呼び出され、  

System.ServiceProcess.ServiceProcessInstaller  
System.ServiceProcess.ServiceInstaller  

2クラスのインスタンスにプロパティ設定をし、リターン値としてC#に引き渡されます。  

動作を変えたい場合は上記2クラスのプロパティやイベントを変えてください。  

Powershellでのイベントの変え方は、下記のURLを参考にしてください。  
（おそらく、add_～メソッドにスクリプトブロックを渡すだけだと思います。）  

[PowerShell]VisualBaiscとPowerShellのイベント処理の比較  
http://d.hatena.ne.jp/newpops/20070120/p1  
