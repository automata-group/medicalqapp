# Deploy updated Admin Dashboard and Backend changes to production server
$distPath = "$PSScriptRoot\admin-dashboard\dist"
$backendController = "$PSScriptRoot\backend\src\controllers\admin\questionController.js"
$server = "root@209.74.82.107"
$port = "22022"
$sshOpts = "-o StrictHostKeyChecking=no -p $port"

Write-Host "=== Deploying Admin Dashboard & Backend to Server ===" -ForegroundColor Cyan

# 1. Upload admin build
Write-Host "[1/4] Uploading admin dashboard build..." -ForegroundColor Yellow
scp -P $port -o StrictHostKeyChecking=no -r "$distPath" "${server}:/tmp/admin-dist"
ssh $sshOpts $server "docker cp /tmp/admin-dist/. medical_qbank_admin:/usr/share/nginx/html/ && rm -rf /tmp/admin-dist"

# 2. Upload backend files
Write-Host "[2/4] Uploading backend files..." -ForegroundColor Yellow
$appJs = "$PSScriptRoot\backend\src\app.js"
scp -P $port -o StrictHostKeyChecking=no "$backendController" "${server}:/tmp/questionController.js"
scp -P $port -o StrictHostKeyChecking=no "$appJs" "${server}:/tmp/app.js"

# 3. Find backend container and apply update
Write-Host "[3/4] Applying backend updates..." -ForegroundColor Yellow
ssh $sshOpts $server "
    BACKEND_CONTAINER=`$(docker ps --filter 'name=backend' --format '{{.Names}}' | head -n 1)
    if [ -n \"`$BACKEND_CONTAINER\" ]; then
        echo \"Found backend container: `$BACKEND_CONTAINER\"
        docker cp /tmp/questionController.js `$BACKEND_CONTAINER:/app/src/controllers/admin/questionController.js
        docker cp /tmp/app.js `$BACKEND_CONTAINER:/app/src/app.js
        rm -f /tmp/questionController.js /tmp/app.js
        docker restart `$BACKEND_CONTAINER
        echo \"Backend restarted successfully with optimizations.\"
    else
        echo \"No container named backend found.\"
    fi
"

Write-Host "[4/4] Done! Changes are live on https://healthlicenseprep.com" -ForegroundColor Green
