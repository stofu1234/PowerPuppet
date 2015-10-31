using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.Threading.Tasks;
using System.ServiceProcess;
using System.Reflection;
using System.Management.Automation;

namespace PowerPuppet
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
    {
        string policyScript = "If((Get-ExecutionPolicy -Scope Process) -ne 'Unrestricted'){" + "\r\n"
                        + "   Set-ExecutionPolicy -ExecutionPolicy 'Unrestricted' -Scope Process" + "\r\n"
                        + "}" + "\r\n";

        string loadScript = "if(Test-Path '{0}' ){{" + "\r\n"
                               + ". '{0}' | Out-Null" + "\r\n"
                               + "}} else {{" + "\r\n"
                               + "'script not found'" + "\r\n"
                               + "}}";
        string serviceScript = "Get-Command -Name getServiceProcessInstaller -Scope Global -ea SilentlyContinue | Out-Null" + "\r\n"
                               + "If($?) { getServiceProcessInstaller }" + "\r\n";

        RunspaceInvoke invoker;

        public ProjectInstaller()
        {
            //System.Diagnostics.Debugger.Launch();

            var assemblyFileBaseName = Path.GetFileNameWithoutExtension(Assembly.GetExecutingAssembly().Location);
            var assemblyFileDirName = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var powershellScriptFullPath = assemblyFileDirName + "\\" + assemblyFileBaseName + ".ps1";
            Console.WriteLine(powershellScriptFullPath);

            this.serviceProcessInstaller1 = new System.ServiceProcess.ServiceProcessInstaller();
            this.serviceInstaller1 = new System.ServiceProcess.ServiceInstaller();

            invoker = new RunspaceInvoke();
            //ポリシー設定(結果は破棄）
            invoker.Invoke(policyScript);
            //スクリプト本体をロード
            Console.WriteLine(String.Format(loadScript, powershellScriptFullPath));
            var result = invoker.Invoke(String.Format(loadScript, powershellScriptFullPath));

            result = invoker.Invoke(serviceScript);
            this.serviceProcessInstaller1 = (ServiceProcessInstaller)result[0].ImmediateBaseObject;
            this.serviceInstaller1 = (ServiceInstaller)result[1].ImmediateBaseObject;


            this.Installers.AddRange(new System.Configuration.Install.Installer[] {
            this.serviceProcessInstaller1,
            this.serviceInstaller1});
        }

        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {

        }


    }
}
