param([string]$sdkManagerPath = "", [string]$sdkManagerArgs = "", [string]$sdkOutput = "")

if ($PSCommandPath -eq $null) 
{ 
	function GetPSCommandPath()
	{ 
		return $MyInvocation.PSCommandPath; 
	} 
	$PSCommandPath = GetPSCommandPath; 
}

Write-Host "Arguments are ""$sdkManagerPath"" ""$sdkManagerArgs"" ""$sdkOutput"""

if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	try
	{
		$args = "$sdkManagerArgs > ""$sdkOutput\SdkToolStdout.txt"" 2> ""$sdkOutput\SdkToolStderr.txt"""
		Write-Host "Executing command $sdkManagerPath $args, don't close this window...."
	
		$psi = New-Object System.Diagnostics.ProcessStartInfo;
		$psi.FileName = "$sdkManagerPath";
		$psi.UseShellExecute = $false; 
		$psi.Arguments = $args;
		$psi.CreateNoWindow = $true;
		$psi.RedirectStandardInput = $true; 
		$p = [System.Diagnostics.Process]::Start($psi);
		$p.StandardInput.WriteLine("y");
		$p.WaitForExit();
		Write-Host "Done "
		exit $p.ExitCode
	}
	catch
	{
		Out-File -FilePath "$sdkOutput\PSElevated.txt" -InputObject $Error[0]
		exit -1
	}
}
else
{
	Write-Warning "WARNING: Administrative privileges required"
	$SDKManagerProcess = $null
	try
	{
		$args = "-ExecutionPolicy Bypass -File ""$PSCommandPath"" -ArgumentList Ignored ""$sdkManagerPath"" ""$sdkManagerArgs"" ""$sdkOutput"""
		$SDKManagerProcess = Start-Process -PassThru -Wait PowerShell.exe -ArgumentList $args -Verb RunAs
	}
	catch
	{
		Write-Warning $Error[0]
		exit -1
	}
	Write-Host "Command finished with exit code:" $SDKManagerProcess.ExitCode
	exit $SDKManagerProcess.ExitCode
}

