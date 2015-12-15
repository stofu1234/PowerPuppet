PowerPuppet
======================
常駐サービスをPowershellで記述するためのC#ラッパー  

###概略
常駐型のサービスをPowershellスクリプトで記述するためのアプリケーションです。 

基本的にはexeの内容は変えず、アプリケーションによってスクリプトの内容を変更することにより  
Windowsのサービスという仕組みの中でUNIXのデーモン起動スクリプトのような手軽さを実現します。  

LinuxのオープンソースアプリがWindowsに移植された場合、  
サービス化されていないままリリースされる事が多々あります。  

想定される使用方法の一つとして、それらをサービス化する、そのハードルを引き下げることができると思います  
（MITライセンスでリリースされた、サンプルのps1を改修することにより、多種のアプリへ容易に対応できます）  

そのような使用方法の場合、スクリプトの内容は主に以下のようになると思います  

* サービス起動・停止ロジック  
* その他エラーハンドリングロジック  
* サービスインストール情報  

その他の使用方法としては以下を想定しています  
* 常駐させることがほぼ必須なFileSystemWatcherと組み合わせるような使い方  
* 通常の監視エージェントとは別に、どうしても独立常駐プロセスで特別に監視をしたい場合  
* その他あなたの考えるWindowsサービスの使い方  

###使用方法
1.プロジェクトをビルドし、PowerPuppet.exeを作成します

MSBuild.exe /property:Configuration=Release PowerPuppet.csproj

（MSBuild.exeは\<windir\>\Microsoft.NET\Framework[|64]\v\*.\*.*****にあります）

2.PowerPuppet.exeを任意の名前にリネームします

例）
PowerPuppet.exe → nginx_service.exe

3.同名の.ps1ファイルを用意します

例）
nginx_service.ps1

4.InstallUtil.exeでリネームしたexeを登録します

例）
InstallUtil.exe nginx_service.exe

（InstallUtil.exeは\<windir\>\Microsoft.NET\Framework[|64]\v\*.\*.*****にあります）

gituhub上のsamplecfgフォルダに以下のサンプルps1があります
* nginx_service.ps1  →　Nginx用サンプルps1
* node_service.ps1   →　Node.js用サンプルps1

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

###残課題
1.Powershell2.0、.NetFramework4.5に依存しているので
  Pashみたいに複数環境に対するビルドができるようにしたいです。
