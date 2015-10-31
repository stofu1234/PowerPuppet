# �T�[�r�X�C���X�g�[�������
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
   $serviceInstaller.Description = "nginx����`��"
   
   # return
   $serviceProcessInstaller
   $serviceInstaller
}

# �T�[�r�X�풓�����W�b�N
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath 2>&1 >>$logPath

   $start = Register-ObjectEvent -InputObject      $timer `
                                 -SourceIdentifier TimerElapsed `
                                 -EventName        Elapsed `
                                 -Action           $watcher.GetNewClosure()
   $timer.start()
   
   "$(timeStamp) Done." >>$logPath
}
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath -Wait -ArgumentList @("-s","quit") 2>&1 >>$logPath
   Unregister-Event TimerElapsed
   "$(timeStamp) Done." >>$logPath
}
function timeStamp{
   Get-Date -Format "yyyy/MM/dd hh:mm:ss.ff"
}
$watcher = {
   #Write-Host "$(timeStamp) watching..."
   "$(timeStamp) watching..." >>$logPath
   $pid = cat $pidPath
   $parentProcess = Get-Process -Id $pid -ea SilentlyContinue
   if(! $?){
      "$(timeStamp) Process[$pid] Notfound. Rebooting..." >>$logPath
      OnStop
      OnStart $null
      "$(timeStamp) Done." >>$logPath
   }
   "$(timeStamp) Done." >>$logPath
}
# �T�[�r�X�ݒ���
$ServiceName = "nginx"
$CanStop     = $true

# �萔
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
$nginxPath  = Join-Path  $scriptPath "nginx.exe"
$logPath    = Join-Path  $scriptPath "nginx_service.log"
$pidPath    = Join-Path  $scriptPath "logs\nginx.pid"

$timer = New-Object System.Timers.Timer
$timer.Interval  = 60e3

# �g�p��@�\��
"Usage: InstallUtil.exe [<service>.exe]"


