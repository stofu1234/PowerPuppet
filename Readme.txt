���\�t�g��
PowerPuppet

���T��
Powershell���T�[�r�X�Ƃ��ď풓�����邽�߂̃��b�p�[C#�A�v���ł��B

���g�p���@
�R���p�C�����Ăł����APowerPuppet.exe��ʖ��ɕς��A
����exe�Ɠ����Ŋg���q��ps1��Powershell�X�N���v�g���L�q���܂��B

�X�N���v�g�̓��e�͎�Ɉȉ��ł��B

�T�[�r�X�N���E��~���W�b�N
���̑��G���[�n���h�����O���W�b�N
�T�[�r�X�C���X�g�[�����

�T���v���Ƃ��āA
nginx_service.exe
nginx_service.ps1
�Ƃ����ꍇ��ps1�t�@�C����

samplecfg�t�H���_�ɔz�u���Ă����܂����B

�T�[�r�X�C���X�g�[������ꍇ��

Example: InstallUtil.exe nginx_service.exe

���Ƃ��Ă��������B

�iInstallUtil��C:\Windows\Microsoft.NET\Framework�`\�e��o�[�W����\
�@�z���ɂ���܂��B�j

������T��
1.�풓�T�[�r�X���쎞�͈ȉ��̃v���p�e�B�E���\�b�h��ps1��ɂ���ꍇ�A
�@�T�[�r�X�N�����ɓ��v���p�e�B��ǂݎ������A
�@���\�b�h�������Ăяo����܂��B
�@�����AC#�T�[�r�X�̎d�l����s�����Ă���v���p�e�B�E���\�b�h������ꍇ��
�@Service1.cs�ɋL�q������̂ŉ��C���Ă��������B

�E�v���p�e�B
ServiceName
CanStop
CanShutdown
CanPauseAndContinue
CanHandlePowerEvent
CanHandleSessionChangeEvent
AutoLog
ExitCode

�E���\�b�h
OnStart
OnStop
OnContinue
OnCustomCommand
OnPause
OnPowerEvent
OnSessionChange
OnShutdown
Dispose

2.�C���X�g�[�����쎞
ps1����getServiceProcessInstaller���Ăяo����A

System.ServiceProcess.ServiceProcessInstaller
System.ServiceProcess.ServiceInstaller

2�N���X�̃C���X�^���X�Ƀv���p�e�B�ݒ�����A���^�[���l�Ƃ���C#�Ɉ����n����܂��B

�����ς������ꍇ�͏�L2�N���X�̃v���p�e�B��C�x���g��ς��Ă��������B

Powershell�ł̃C�x���g�̕ς����́A���L��URL���Q�l�ɂ��Ă��������B
�i�����炭�Aadd_�`���\�b�h�ɃX�N���v�g�u���b�N��n���������Ǝv���܂��B�j

[PowerShell]VisualBaisc��PowerShell�̃C�x���g�����̔�r
http://d.hatena.ne.jp/newpops/20070120/p1




