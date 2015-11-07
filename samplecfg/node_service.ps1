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
   $serviceInstaller.ServiceName = "nodejs"
   $serviceInstaller.DisplayName = "node.js"
   $serviceInstaller.Description = "node.jsだよ～ん"
   
   # return
   $serviceProcessInstaller
   $serviceInstaller
}

## サービス常駐時ロジック
# サービス開始
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   #$parentProcess = Start-Process -FilePath $nodePath -ArgumentList $targetJs -PassThru
   $script:parentProcess = Start-Process -FilePath $nodePath -ArgumentList $targetJs -PassThru
   
   $parentProcess.id > $pidPath
   
   # プロセス監視開始
   $start = Register-ObjectEvent -InputObject      $timer `
                                 -SourceIdentifier $sourceIdentifier `
                                 -EventName        $eventName `
                                 -Action           $watcher.GetNewClosure()
   $timer.start()

   "$(timeStamp) parent process pid:"+$($parentProcess.id) >>$logPath

   Start-Sleep $childProcessWaitTime
   
   # node.jsの子プロセスを取得
   $parentProcessQuery = "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {0}"
   $script:childProcesses = Get-Process | ? {$_.Name -eq $appProcessName} | ? {$_.id -ne $parentProcess.id } | ? {
      $ppid = (Get-WmiObject -query ($parentProcessQuery -F $_.id)).ParentProcessId 2>$null
      "$(timeStamp) ppid:"+$ppid >>$logPath
      $parentProcess.id -eq $ppid
   }
   "$(timeStamp) child processes:"+($script:childProcesses | % {$_.id}) >>$logPath
   "$(timeStamp) Done." >>$logPath
}
# サービス停止
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Stop-Process -InputObject $parentProcess
   
   Remove-Item -Path $pidPath
   
   # プロセス監視停止
   Unregister-Event -SourceIdentifier $sourceIdentifier
   "$(timeStamp) childProcess:"+$childProcesses >>$logPath
   # node.jsの子プロセスをキル
     Get-Process -InputObject $childProcesses -ea SilentlyContinue `
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
   $parentProcess = Get-Process -InputObject $parentProcess -ea SilentlyContinue
   if(! $?){
      "$(timeStamp) Process[$($parentProcess.id)] not found. Rebooting..." >>$logPath
      OnStop
      OnStart $null
      "$(timeStamp) Done." >>$logPath
   }
   "$(timeStamp) Done." >>$logPath
}

# サービス設定情報
$ServiceName = "nodejs"
$CanStop     = $true

# 定数
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
#$scriptPath = "E:\Users\naomasa\Documents\node"
$nodePath   = "node.exe"
$targetJs   = Join-Path  $scriptPath "http.js"
$logPath    = Join-Path  $scriptPath "node_service.log"
$pidPath    = Join-Path  $scriptPath "node.pid"

$appProcessName     = "node"
$childProcesses     = $null

$childProcessWaitTime  = 1

# プロセス監視用タイマー
$timer = New-Object System.Timers.Timer
$timer.Interval  = 10e3      #プロセス監視間隔 10秒

$sourceIdentifier = "TimerElapsed"
$eventName        = "Elapsed"


"Usage: InstallUtil.exe [<service>.exe]"
