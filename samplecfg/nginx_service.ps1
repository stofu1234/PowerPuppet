# サービスインストール時情報
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

# サービス常駐時ロジック
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath 2>&1 >>$logPath
   "$(timeStamp) Done." >>$logPath
}
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath -Wait -ArgumentList @("-s","quit") 2>&1 >>$logPath
   "$(timeStamp) Done." >>$logPath
}
function timeStamp{
   Get-Date -Format "yyyy/MM/dd hh:mm:ss.ff"
}

# 定数
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
$nginxPath  = Join-Path  $scriptPath "nginx.exe"           #　nginx.exeは本スクリプトと同一フォルダに配置
$logPath    = Join-Path  $scriptPath "nginx_service.log"
$pidPath    = Join-Path  $scriptPath "logs\nginx.pid"

# サービス設定情報
$ServiceName = "nginx"
$CanStop     = $true


# 使用例　表示
"Usage: InstallUtil.exe [<service>.exe]"




