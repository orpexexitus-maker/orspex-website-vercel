Set-Location "C:\orspex-website-vercel"

Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ORSPEX SEO Health Check" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════`n" -ForegroundColor Cyan

$files = Get-ChildItem -Recurse -Filter "*.html"
$ok = 0
$issues = 0

foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw
    $path = $f.FullName.Replace("C:\orspex-website-vercel\","")

    $t  = if ($c -match '<title>([^<]+)</title>')                       { $matches[1] } else { "" }
    $d  = if ($c -match '<meta name="description" content="([^"]+)"')   { $matches[1] } else { "" }
    $cn = if ($c -match '<link rel="canonical" href="([^"]+)"')         { $matches[1] } else { "" }

    $issues_page = @()
    if (-not $t)                          { $issues_page += "no title" }
    if ($t.Length -gt 60)                 { $issues_page += "title too long ($($t.Length))" }
    if (-not $d)                          { $issues_page += "no description" }
    if ($d.Length -gt 160)                { $issues_page += "desc too long ($($d.Length))" }
    if (-not $cn)                         { $issues_page += "no canonical" }
    if (-not $c.Contains('og:title'))     { $issues_page += "no og:title" }
    if (-not $c.Contains('twitter:card')) { $issues_page += "no twitter card" }

    if ($issues_page.Count -eq 0) {
        Write-Host "OK   $path" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "FAIL $path" -ForegroundColor Red
        $issues_page | ForEach-Object { Write-Host "       - $_" -ForegroundColor Yellow }
        $issues++
    }
}

Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Passed: $ok / $($files.Count)" -ForegroundColor $(if ($issues -eq 0) { "Green" } else { "Yellow" })
if ($issues -gt 0) { Write-Host "  Issues: $issues pages" -ForegroundColor Red }
Write-Host "═══════════════════════════════════════════`n" -ForegroundColor Cyan
