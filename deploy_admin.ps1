# Deploy Optimized Admin Dashboard to Server
# This script uploads the new optimized build files to the Docker container

Write-Host "=== Deploying Optimized Admin Dashboard ===" -ForegroundColor Cyan
Write-Host ""

$distPath = "$PSScriptRoot\admin-dashboard\dist"
$server = "root@209.74.82.107"
$port = "22022"
$sshOpts = "-o StrictHostKeyChecking=no -p $port"

# Step 1: Upload the dist folder to the server
Write-Host "[1/4] Uploading optimized build files to server..." -ForegroundColor Yellow
scp -P $port -o StrictHostKeyChecking=no -r "$distPath" "${server}:/tmp/admin-dist"

# Step 2: Copy files into the running Docker container
Write-Host "[2/4] Replacing files inside Docker container..." -ForegroundColor Yellow
ssh $sshOpts $server "docker cp /tmp/admin-dist/. medical_qbank_admin:/usr/share/nginx/html/"

# Step 3: Verify the new files
Write-Host "[3/4] Verifying new files inside container..." -ForegroundColor Yellow
ssh $sshOpts $server "docker exec medical_qbank_admin ls -la /usr/share/nginx/html/assets/ | head -30"

# Step 4: Cleanup
Write-Host "[4/4] Cleaning up temp files..." -ForegroundColor Yellow
ssh $sshOpts $server "rm -rf /tmp/admin-dist"

Write-Host ""
Write-Host "=== Deployment Complete! ===" -ForegroundColor Green
Write-Host "Open https://healthlicenseprep.com and press Ctrl+Shift+R to hard reload." -ForegroundColor Cyan
