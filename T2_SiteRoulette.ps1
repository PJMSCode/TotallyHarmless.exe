# List of popular top-level domains
$topLevelDomains = @(".com", ".net", ".org", ".info", ".biz", ".io", ".co", ".us", ".me", ".tv")

# List of common website prefixes
$websitePrefixes = @("www", "blog", "news", "shop", "forum", "store", "wiki", "mail", "support", "help")

# Generate random websites
$websites = @()
for ($i = 1; $i -le 100; $i++) {
    $prefix = Get-Random -InputObject $websitePrefixes
    $suffix = Get-Random -InputObject $topLevelDomains
    $websites += "$prefix.example$suffix"
}

# Save websites to a text file
$websites | Out-File -FilePath "random_websites.txt"

Write-Host "List of random websites saved to random_websites.txt"
