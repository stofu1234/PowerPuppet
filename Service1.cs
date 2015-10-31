using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using System.Management.Automation;

namespace PowerPuppet
{
    public partial class Service1 : ServiceBase
    {
        string functionInvoke = "Get-Command -Name {0} -Scope Global -ea SilentlyContinue | Out-Null" + "\r\n"
                       + "If($?) {{ {0}($input) }}";
        string variableInvoke = "Get-Variable {0} -ea SilentlyContinue | Out-Null" + "\r\n"
                               + "If($?) {{ ${0} }}";
        string policyScript = "If((Get-ExecutionPolicy -Scope Process) -ne 'Unrestricted'){" + "\r\n"
                       + "   Set-ExecutionPolicy -ExecutionPolicy 'Unrestricted' -Scope Process" + "\r\n"
                       + "}" + "\r\n";
        string loadScript = "if(Test-Path '{0}' ){{" + "\r\n"
                               + ". '{0}' | Out-Null" + "\r\n"
                               + "}} else {{" + "\r\n"
                               + "'script not found'" + "\r\n"
                               + "}}";

        RunspaceInvoke invoker;

        public Service1()
        {

            var assemblyFileBaseName = Path.GetFileNameWithoutExtension(Assembly.GetExecutingAssembly().Location);
            var assemblyFileDirName = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var powershellScriptFullPath = assemblyFileDirName + "\\" + assemblyFileBaseName + ".ps1";
            Console.WriteLine(powershellScriptFullPath);

            invoker = new RunspaceInvoke();

            //ポリシー設定(結果は破棄）
            invoker.Invoke(policyScript);
            //スクリプト本体をロード
            Console.WriteLine(String.Format(loadScript, powershellScriptFullPath));
            invoker.Invoke(String.Format(loadScript, powershellScriptFullPath));


            //InitializeComponent();
            InitilizeFromScript();
        }

        private void InitilizeFromScript()
        {
            components = new System.ComponentModel.Container();

            // 1.ServiceName
            var result = invoker.Invoke(String.Format(variableInvoke, "ServiceName"));
            if (result.Count == 1)
            {
                this.ServiceName = result[0].ToString();
                Console.WriteLine("サービス名:" + this.ServiceName);
            }
            else
            {
                this.ServiceName = "Service1";
                Console.WriteLine("サービス名が取得できませんでした。デフォルトサービス名Service1を設定します");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 2.CanStop
            result = invoker.Invoke(String.Format(variableInvoke, "CanStop"));
            if (result.Count == 1)
            {
                this.CanStop = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("CanStop:" + this.CanStop);
            }
            else
            {
                Console.WriteLine("CanStopが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 3.CanShutdown
            result = invoker.Invoke(String.Format(variableInvoke, "CanShutdown"));
            if (result.Count == 1)
            {
                this.CanShutdown = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("CanShutdown:" + this.CanShutdown);
            }
            else
            {
                Console.WriteLine("CanShutdownが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 4.CanPauseAndContinue
            result = invoker.Invoke(String.Format(variableInvoke, "CanPauseAndContinue"));
            if (result.Count == 1)
            {
                this.CanPauseAndContinue = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("CanPauseAndContinue:" + this.CanPauseAndContinue);
            }
            else
            {
                Console.WriteLine("CanPauseAndContinueが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 5.CanHandlePowerEvent
            result = invoker.Invoke(String.Format(variableInvoke, "CanHandlePowerEvent"));
            if (result.Count == 1)
            {
                this.CanHandlePowerEvent = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("CanHandlePowerEvent:" + this.CanHandlePowerEvent);
            }
            else
            {
                Console.WriteLine("CanHandlePowerEventが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 6.CanHandleSessionChangeEvent
            result = invoker.Invoke(String.Format(variableInvoke, "CanHandleSessionChangeEvent"));
            if (result.Count == 1)
            {
                this.CanHandleSessionChangeEvent = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("CanHandleSessionChangeEvent:" + this.CanHandleSessionChangeEvent);
            }
            else
            {
                Console.WriteLine("CanHandleSessionChangeEventが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 7.AutoLog
            result = invoker.Invoke(String.Format(variableInvoke, "AutoLog"));
            if (result.Count == 1)
            {
                this.AutoLog = (bool)result[0].ImmediateBaseObject;
                Console.WriteLine("AutoLog:" + this.AutoLog);
            }
            else
            {
                Console.WriteLine("AutoLogが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }
            // 8.ExitCode
            result = invoker.Invoke(String.Format(variableInvoke, "ExitCode"));
            if (result.Count == 1)
            {
                this.ExitCode = (int)result[0].ImmediateBaseObject;
                Console.WriteLine("ExitCode:" + this.ExitCode);
            }
            else
            {
                Console.WriteLine("ExitCodeが取得できませんでした。");
                foreach (var r in result)
                {
                    Console.WriteLine(r);
                }
            }


        }

        protected override void OnStart(string[] args)
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnStart"), args);
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }

        protected override void OnStop()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnStop"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
        protected override void OnContinue()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnContinue"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
        protected void OnCustomCommand()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnCustomCommand"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
        protected override void OnPause()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnPause"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }

        protected void OnPowerEvent()
        {

            var result = invoker.Invoke(String.Format(functionInvoke, "OnPowerEvent"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
        protected void OnSessionChange()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnSessionChange"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
        protected override void OnShutdown()
        {
            var result = invoker.Invoke(String.Format(functionInvoke, "OnShutdown"));
            foreach (var r in result)
            {
                Console.WriteLine(r);
            }
        }
    }
}
