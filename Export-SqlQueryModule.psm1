$libraryName = "CodeSanook.SqlGenerator"
$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "CodeSanook.SqlGenerator/bin/Release/"
$assemblyPath = Join-Path -Path $outputDir -ChildPath "$libraryName.dll"
$assemblyPath

#LoadFrom(), search all dependent DLLs in the same directory
$assembly = [Reflection.Assembly]::LoadFrom($assemblyPath)
$assembly
"assembly loaded"

function Export-SqlQuery {
    param(
        [Parameter(Mandatory = $True)] [string] $ConnectionString,
        [Parameter(Mandatory = $True)]
        [CodeSanook.SqlGenerator.DatabaseType] $DatabaseType,
        [Parameter(Mandatory = $True)] [string] $Query,
        [Parameter(Mandatory = $True)] [string] $Template,
        [Parameter(Mandatory = $True)] [string] $FilePath
    )

    #prepare parameters object
    $options = New-Object CodeSanook.SqlGenerator.ExportOptions
    $options.DatabaseType = $DatabaseType
    $options.ConnectionString = $ConnectionString
    $options.Query = $Query
    $options.Template = $Template

    $fileStream = New-Object `
        -TypeName System.IO.FileStream `
        -ArgumentList @($FilePath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
    $options.Stream = $fileStream

    # Export SQL query and pipe to a file
    $tool = New-Object CodeSanook.SqlGenerator.SqlExportTool
    $tool.Export($options)
    $fileStream.Close()
    $fileStream.Dispose()

    "exported"
}

function Get-ConnectionString {
    param(
        [Parameter(Mandatory = $True)] [string] $Server,
        [Parameter(Mandatory = $True)] [string] $Database,
        [Parameter(Mandatory = $False)] [string] $Username,
        [Parameter(Mandatory = $False)] [string] $Password
    )

    if ($Password) {
        $connectionString = "Server=$Server;Database=$Database;User Id=$Username; Password=$Password;"
    }
    else {
        #Trusted Connection Windows user login
        $connectionString = "Server=$Server;Database=$Database;Trusted_Connection=True";
    }

    $connectionString
}

Export-ModuleMember -Function "Export-SqlQuery"
Export-ModuleMember -Function "Get-ConnectionString"
