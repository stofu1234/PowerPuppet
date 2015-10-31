## サービスインストール時
function getServiceProcessInstaller{
   $sp = "System.ServiceProcess"
   Add-type -AssemblyName $sp
   $serviceProcessInstaller = New-Object "$sp.ServiceProcessInstaller"
   $serviceInstaller        = New-Object "$sp.ServiceInstaller"
   
   $localSystem = [System.ServiceProcess.ServiceAccount]::LocalSystem
   $manual      = [System.ServiceProcess.ServiceStartMode]::Manual
   $automatic   = [System.ServiceProcess.ServiceStartMode]::Automatic
   
   $serviceProcessInstaller.Account = $localSystem

   $serviceInstaller.StartType   = $automatic
   $serviceInstaller.ServiceName = "nginx"
   $serviceInstaller.DisplayName = "Nginx"
   $serviceInstaller.Description = "nginxだよ～ん"
   
   # return
   $serviceProcessInstaller
   $serviceInstaller
}

## サービス常駐時ロジック
# サービス開始
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath 2>&1 >>$logPath
   # 子プロセス監視開始
   $start = Register-ObjectEvent -InputObject      $timer `
                                 -SourceIdentifier TimerElapsed `
                                 -EventName        Elapsed `
                                 -Action           $watcher.GetNewClosure()
   $timer.start()

   # nginxの親プロセスIDを取得、pidファイル出力待機
   while($true){
      if(Test-Path $pidPath){
         $parentProcessID    = cat $pidPath
         break
      } else {
         Start-Sleep -Milliseconds 500
      }
   }
   "$(timeStamp) parent process pid:"+$parentProcessID >>$logPath

   # nginxの子プロセスを取得
   $parentProcessQuery = "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {0}"
   $script:childProcesses = Get-Process | ? {$_.Name -eq $appProcessName} | ? {$_.id -ne $parentProcessID } | ? {
      $ppid = (Get-WmiObject -query ($parentProcessQuery -F $_.id)).ParentProcessId 2>$null
      $parentProcessID -eq $ppid
   }
   "$(timeStamp) child processes:"+($script:childProcesses | % {$_.id}) >>$logPath
   "$(timeStamp) Done." >>$logPath
}
# サービス停止
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath -ArgumentList @("-s","quit") 2>&1 >>$logPath

   # 子プロセス監視停止
   Unregister-Event TimerElapsed
   
   # nginx pid 削除待ち wait処理
   Start-Sleep -Milliseconds 500
   while($true){
      if(Test-Path $pidPath){
         Start-Sleep -Milliseconds 500
      } else {
         break
      }
   }
   # nginxの子プロセスをキル
     Get-Process -InputObject $childProcesses -ea SilentlyContinue `
   | ? {! $_.WaitForExit(1000)} `
   | % { 
         "$(timeStamp) killing process:"+$_.id+" HasExited:"+$_.HasExited >>$logPath
         Stop-Process -InputObject $_ -Force
       }
   "$(timeStamp) Done." >>$logPath
}

# ログ出力時刻表示
function timeStamp{
   Get-Date -Format "yyyy/MM/dd HH:mm:ss.ff"
}

# プロセス監視
$watcher = {
   #Write-Host "$(timeStamp) watching..."
   "$(timeStamp) watching..." >>$logPath
   $pid = cat $pidPath
   $parentProcess = Get-Process -Id $pid -ea SilentlyContinue
   if(! $?){
      "$(timeStamp) Process[$pid] not found. Rebooting..." >>$logPath
      OnStop
      OnStart $null
      "$(timeStamp) Done." >>$logPath
   }
   "$(timeStamp) Done." >>$logPath
}

# サービス設定情報
$ServiceName = "nginx"
$CanStop     = $true

# 定数
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
$nginxPath  = Join-Path  $scriptPath "nginx.exe"
$logPath    = Join-Path  $scriptPath "nginx_service.log"
$pidPath    = Join-Path  $scriptPath "logs\nginx.pid"

$appProcessName     = "nginx"
$childProcesses     = $null

# プロセス監視用タイマー
$timer = New-Object System.Timers.Timer
$timer.Interval  = 10e3      #プロセス監視間隔 10秒


"Usage: InstallUtil.exe [<service>.exe]"
