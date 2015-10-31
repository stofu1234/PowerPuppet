## �T�[�r�X�C���X�g�[����
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

## �T�[�r�X�풓�����W�b�N
# �T�[�r�X�J�n
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath 2>&1 >>$logPath
   # �q�v���Z�X�Ď��J�n
   $start = Register-ObjectEvent -InputObject      $timer `
                                 -SourceIdentifier TimerElapsed `
                                 -EventName        Elapsed `
                                 -Action           $watcher.GetNewClosure()
   $timer.start()

   # nginx�̐e�v���Z�XID���擾�Apid�t�@�C���o�͑ҋ@
   while($true){
      if(Test-Path $pidPath){
         $parentProcessID    = cat $pidPath
         break
      } else {
         Start-Sleep -Milliseconds 500
      }
   }
   "$(timeStamp) parent process pid:"+$parentProcessID >>$logPath

   # nginx�̎q�v���Z�X���擾
   $parentProcessQuery = "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {0}"
   $script:childProcesses = Get-Process | ? {$_.Name -eq $appProcessName} | ? {$_.id -ne $parentProcessID } | ? {
      $ppid = (Get-WmiObject -query ($parentProcessQuery -F $_.id)).ParentProcessId 2>$null
      $parentProcessID -eq $ppid
   }
   "$(timeStamp) child processes:"+($script:childProcesses | % {$_.id}) >>$logPath
   "$(timeStamp) Done." >>$logPath
}
# �T�[�r�X��~
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Start-Process -FilePath $nginxPath -ArgumentList @("-s","quit") 2>&1 >>$logPath

   # �q�v���Z�X�Ď���~
   Unregister-Event TimerElapsed
   
   # nginx pid �폜�҂� wait����
   Start-Sleep -Milliseconds 500
   while($true){
      if(Test-Path $pidPath){
         Start-Sleep -Milliseconds 500
      } else {
         break
      }
   }
   # nginx�̎q�v���Z�X���L��
     Get-Process -InputObject $childProcesses -ea SilentlyContinue `
   | ? {! $_.WaitForExit(1000)} `
   | % { 
         "$(timeStamp) killing process:"+$_.id+" HasExited:"+$_.HasExited >>$logPath
         Stop-Process -InputObject $_ -Force
       }
   "$(timeStamp) Done." >>$logPath
}

# ���O�o�͎����\��
function timeStamp{
   Get-Date -Format "yyyy/MM/dd HH:mm:ss.ff"
}

# �v���Z�X�Ď�
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

# �T�[�r�X�ݒ���
$ServiceName = "nginx"
$CanStop     = $true

# �萔
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
$nginxPath  = Join-Path  $scriptPath "nginx.exe"
$logPath    = Join-Path  $scriptPath "nginx_service.log"
$pidPath    = Join-Path  $scriptPath "logs\nginx.pid"

$appProcessName     = "nginx"
$childProcesses     = $null

# �v���Z�X�Ď��p�^�C�}�[
$timer = New-Object System.Timers.Timer
$timer.Interval  = 10e3      #�v���Z�X�Ď��Ԋu 10�b


"Usage: InstallUtil.exe [<service>.exe]"
