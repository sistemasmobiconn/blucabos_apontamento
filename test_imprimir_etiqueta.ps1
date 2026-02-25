# PowerShell script to test the imprimirEtiqueta endpoint

# Define the endpoint URL
$url = "http://179.118.199.109:9092/datasnap/rest/tsmfv/ImprimirEtiqueta"

# Define the JSON body
$body = @{
	"cod_empresa"   = 2
	"num_ordem"     = 501234
	"id_apon"       = 3259
	"id_apon_lote"  = 10337
	"id_impressora" = 1
} | ConvertTo-Json

# Define headers
$headers = @{
	
}

Write-Host "Testing endpoint: $url" -ForegroundColor Green
Write-Host "Request body:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Cyan

try {
	# Make the HTTP POST request
	$response = Invoke-RestMethod -Uri $url -Method POST -Body $body -Headers $headers -TimeoutSec 30
    
	Write-Host "`nRequest successful!" -ForegroundColor Green
	Write-Host "Response:" -ForegroundColor Yellow
	Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor Cyan
    
}
catch {
	Write-Host "`nRequest failed!" -ForegroundColor Red
	Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
	# Try to get more details from the response if available
	if ($_.Exception.Response) {
		Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
		Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
        
		# Try to read the response content
		try {
			$reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
			$responseBody = $reader.ReadToEnd()
			$reader.Close()
			Write-Host "Response Body: $responseBody" -ForegroundColor Red
		}
		catch {
			Write-Host "Could not read response body" -ForegroundColor Red
		}
	}
}

Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
