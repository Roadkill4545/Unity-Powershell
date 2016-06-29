Function Test-UnityConnection {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [Array]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
  )
  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {
    Foreach ($Sess in $session) {

      Write-Verbose "Processing Array: $($sess.Server)"

      $Websession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
      Foreach ($cookie in $sess.Cookies) {
        Write-Verbose "Ajout cookie: $($cookie.Name)"
        $Websession.Cookies.Add($cookie);
      }

      $URI = 'https://'+$sess.Server+'/api/types/system/instances'

      Write-Verbose "URI: $URI"

      Try {
        $request = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $Websession -Headers $sess.headers -Method 'GET'
      }

      Catch {
        $global:DefaultUnitySession |
          where-object {$_.SessionId -eq $sess.SessionId} |
            foreach {
              $currentObject = $_
              $currentObject.IsConnected = $false
              $currentObject
            } | Out-Null
        Return $false
      }
    }
    Return $True
  }
  End {}
}