#Requires -Version 5
[CmdletBinding()]
param
(
	[ValidateNotNullOrEmpty()]
	[string] $Path = "${ENV:PROGRAMFILES}\Microsoft Forefront Identity Manager\2010\Synchronization Service"
)

if (-not (Test-Path -Path $Path -PathType Container)) {
	Write-Error -Message "The installation path '$($Path)' could not be found or access is denied." -ErrorAction Stop
}

function Add-PSTypeAccelerator {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[Type] $Type,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[Alias('Alias')]
		[string] $Name = $Type.Name,

		[switch] $Force = $false
	)

	begin {
		$PSTypeAccelerators = [Type]::GetType("System.Management.Automation.TypeAccelerators, $([PSObject].Assembly.FullName)")
	}

	process {
		if ($PSTypeAccelerators::Get.ContainsKey($Name)) {
			if ($Force) {
				$PSTypeAccelerators::Remove($Name) | Out-Null
			} else {
				Write-Warning -Message "The alias '$($Name)' already exists, use the -Force switch to replace."
				return # this is like a continue statement in a loop
			}
		}

		$PSTypeAccelerators::Add($Name, $Type)
	}
}

Add-Type -Path (Join-Path -Path $Path -ChildPath 'Bin\Assemblies\Microsoft.MetadirectoryServicesEx.dll')

# Import all public types from Microsoft.MetadirectoryServices (exclude interfaces)
[Microsoft.MetadirectoryServices.MVEntry].Assembly.GetTypes() |? { ($_.Namespace -eq 'Microsoft.MetadirectoryServices') -and (-not $_.IsInterface) } | Add-PSTypeAccelerator
