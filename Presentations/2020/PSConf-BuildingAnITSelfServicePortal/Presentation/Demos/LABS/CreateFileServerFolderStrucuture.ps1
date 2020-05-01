
#
# Create File Structure

$CSV = Import-Csv -Path C:\SCRIPTS\FolderStructure.csv
$CSV | ForEach-Object {
    New-Item -Path $_.Path -ItemType Directory -Force
}

#
# Create Random Files

$CSV | ForEach-Object {
    $path = $_.path
    0 .. 20 | ForEach-Object { "SAMPLE DATA" | Out-File -LiteralPath ("{0}\{1}.sample" -f $path, (Get-Random)) }
}