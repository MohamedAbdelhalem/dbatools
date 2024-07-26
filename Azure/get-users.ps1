$azusers = az account list
$accounts = $azusers | ConvertFrom-Json
$accounts.user.name

az billing account list-invoice-section --billing-account-name $accounts.id
