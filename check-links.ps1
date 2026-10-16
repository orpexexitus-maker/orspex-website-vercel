$base = "http://localhost:9000"
$root = "C:\orspex-website-vercel"
$files = Get-ChildItem $root -Recurse -Filter "*.html"

$links = @()
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Split into lines and skip lines containing escaped HTML (code samples)
    $lines = $content -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match '&lt;|&gt;') { continue }   # skip code samples

        $matches = [regex]::Matches($line, '(?:href|src)="([^"]+)"')
        foreach ($m in $matches) {
            $url = $m.Groups[1].Value

            if ($url -match '^(#|mailto:|javascript:|https?://)') { continue }
            if ($url -match "['+]|\s") { continue }

            if ($url.StartsWith("/")) {
                $full = "$base$url"
            } else {
                $relativeDir = $file.DirectoryName.Replace($root, "").Replace("\", "/")
                $full = "$base$relativeDir/$url"
            }

            $links += [PSCustomObject]@{ Page = $file.Name; Link = $url; URL = $full }
        }
    }
}

foreach ($l in $links) {
    try {
        $r = Invoke-WebRequest -Uri $l.URL -Method Head -UseBasicParsing -ErrorAction Stop
        Write-Host "OK   $($r.StatusCode)  $($l.URL)" -ForegroundColor Green
    } catch {
        Write-Host "FAIL      $($l.URL)  (from $($l.Page))" -ForegroundColor Red
    }
}
