# Generate self-signed SSL certificate for nginx
# This creates a certificate suitable for development/testing

Write-Host "Generating self-signed SSL certificate..." -ForegroundColor Cyan

# Create certificate request file
$infContent = @"
[Version]
Signature= `$Windows NT`

[NewRequest]
Subject = "CN=localhost"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = Cert
KeyUsage = 0xA0

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "DNS=localhost&"
"@

$infContent | Out-File -FilePath "certreq.inf" -Encoding ASCII

# Generate certificate
certreq -new certreq.inf nginx-selfsigned.crt 2>&1 | Out-Null

if (Test-Path "nginx-selfsigned.crt") {
    Write-Host "Certificate generated: nginx-selfsigned.crt" -ForegroundColor Green
    
    # Export private key (requires additional steps)
    Write-Host "Note: Private key needs to be exported separately" -ForegroundColor Yellow
    Write-Host "For nginx, you may need to use OpenSSL or convert the certificate" -ForegroundColor Yellow
} else {
    Write-Host "Certificate generation failed. Using placeholder..." -ForegroundColor Red
    # Create placeholder files
    "" | Out-File -FilePath "nginx-selfsigned.crt"
    "" | Out-File -FilePath "nginx-selfsigned.key"
}
