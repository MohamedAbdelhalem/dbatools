$azusers = az account list
$accounts = $azusers | ConvertFrom-Json
$accounts.user.name
