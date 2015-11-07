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
   $serviceInstaller.ServiceName = "nodejs"
   $serviceInstaller.DisplayName = "node.js"
   $serviceInstaller.Description = "node.js����`��"
   
   # return
   $serviceProcessInstaller
   $serviceInstaller
}

## �T�[�r�X�풓�����W�b�N
# �T�[�r�X�J�n
function OnStart($args){
   "$(timeStamp) Script is starting..." >>$logPath
   cd $scriptPath
   #$parentProcess = Start-Process -FilePath $nodePath -ArgumentList $targetJs -PassThru
   $script:parentProcess = Start-Process -FilePath $nodePath -ArgumentList $targetJs -PassThru
   
   $parentProcess.id > $pidPath
   
   # �v���Z�X�Ď��J�n
   $start = Register-ObjectEvent -InputObject      $timer `
                                 -SourceIdentifier $sourceIdentifier `
                                 -EventName        $eventName `
                                 -Action           $watcher.GetNewClosure()
   $timer.start()

   "$(timeStamp) parent process pid:"+$($parentProcess.id) >>$logPath

   Start-Sleep $childProcessWaitTime
   
   # node.js�̎q�v���Z�X���擾
   $parentProcessQuery = "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {0}"
   $script:childProcesses = Get-Process | ? {$_.Name -eq $appProcessName} | ? {$_.id -ne $parentProcess.id } | ? {
      $ppid = (Get-WmiObject -query ($parentProcessQuery -F $_.id)).ParentProcessId 2>$null
      "$(timeStamp) ppid:"+$ppid >>$logPath
      $parentProcess.id -eq $ppid
   }
   "$(timeStamp) child processes:"+($script:childProcesses | % {$_.id}) >>$logPath
   "$(timeStamp) Done." >>$logPath
}
# �T�[�r�X��~
function OnStop(){
   "$(timeStamp) Script is stopping..." >>$logPath
   cd $scriptPath
   Stop-Process -InputObject $parentProcess
   
   Remove-Item -Path $pidPath
   
   # �v���Z�X�Ď���~
   Unregister-Event -SourceIdentifier $sourceIdentifier
   "$(timeStamp) childProcess:"+$childProcesses >>$logPath
   # node.js�̎q�v���Z�X���L��
     Get-Process -InputObject $childProcesses -ea SilentlyContinue `
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
   $parentProcess = Get-Process -InputObject $parentProcess -ea SilentlyContinue
   if(! $?){
      "$(timeStamp) Process[$($parentProcess.id)] not found. Rebooting..." >>$logPath
      OnStop
      OnStart $null
      "$(timeStamp) Done." >>$logPath
   }
   "$(timeStamp) Done." >>$logPath
}

# �T�[�r�X�ݒ���
$ServiceName = "nodejs"
$CanStop     = $true

# �萔
$scriptPath = Split-Path $script:myInvocation.MyCommand.path -parent
#$scriptPath = "E:\Users\naomasa\Documents\node"
$nodePath   = "node.exe"
$targetJs   = Join-Path  $scriptPath "http.js"
$logPath    = Join-Path  $scriptPath "node_service.log"
$pidPath    = Join-Path  $scriptPath "node.pid"

$appProcessName     = "node"
$childProcesses     = $null

$childProcessWaitTime  = 1

# �v���Z�X�Ď��p�^�C�}�[
$timer = New-Object System.Timers.Timer
$timer.Interval  = 10e3      #�v���Z�X�Ď��Ԋu 10�b

$sourceIdentifier = "TimerElapsed"
$eventName        = "Elapsed"


"Usage: InstallUtil.exe [<service>.exe]"
