SonarQube.Scanner.MSBuild.exe begin /k:"wegmans:mim.powershell" /n:"MIM PowerShell Sync API" /v:"1.0"
MSBuild.exe /t:Rebuild
SonarQube.Scanner.MSBuild.exe end