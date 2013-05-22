$base = (Get-Item ..).FullName
$lib = Join-Path $base 'lib'
$pkg = Join-Path $base 'pkg'
$out = Join-Path $base 'out'

$nuget = "$lib\NuGet.CommandLine.*\tools\NuGet.exe"

Task Default -depends Publish

Task Publish -depends Initialize-Directories, Create-NuGetPackages

Task Initialize-Directories {
  if(Test-Path $out) {
    Remove-Item -Recurse -Force $out
  }
  
  New-Item $out -Type directory  
}

Task Create-NuGetPackages {
  Push-Location $out
  
  Get-ChildItem $pkg -Recurse -Filter *.nuspec | ForEach {
    $spec = $_.FullName
    Exec { Invoke-Expression "$nuget pack $spec" }
  }
  
  Pop-Location
}

Task Push-Packages {
  $apiKey = '';
  if($args.Length -eq 1)
  {
    $apiKey = $args[0]
  }
  else
  {
    Write-Host 'API key: ' -NoNewline
    $apiKey = read-host
  }

  Get-ChildItem $out -Filter *.nupkg | ForEach {
    $pkg = $_.FullName
    Exec { Invoke-Expression "$nuget push $pkg $apiKey" }
  }
}