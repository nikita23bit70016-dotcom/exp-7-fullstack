$mdFile = "OUTPUT_DEMO.md"
"## Experiment 7: Spring Security with JWT and RBAC - Live Demo Output`r`n" | Out-File $mdFile

"### 1. Starting the Spring Boot Backend" | Out-File -Append $mdFile
"Starting application..." | Out-File -Append $mdFile

# Start app in background
$appProcess = Start-Process -FilePath ".\mvnw.cmd" -ArgumentList "spring-boot:run" -PassThru -WindowStyle Hidden -RedirectStandardOutput "app.log" -RedirectStandardError "app_err.log"

# Wait for application to be up
$started = $false
for ($i=0; $i -lt 40; $i++) {
    Start-Sleep -Seconds 2
    if (Test-Path "app.log") {
        $logContent = Get-Content "app.log" -Tail 100 2>$null
        if ($logContent -match "Started Exp7Application") {
            $started = $true
            break
        }
    }
}

if (-not $started) {
    "**Error:** Application did not start in time. Check app.log." | Out-File -Append $mdFile
    Stop-Process -Id $appProcess.Id -Force
    exit
}

"Application started successfully on port 8085.`r`n" | Out-File -Append $mdFile

"### 2. Registering Users`r`n" | Out-File -Append $mdFile

"**Registering 'demouser' (ROLE_USER):**" | Out-File -Append $mdFile
$bodyUser = @{ username="demouser"; password="password123"; roles=@("user") } | ConvertTo-Json
$res1 = Invoke-RestMethod -Uri "http://localhost:8085/api/auth/register" -Method Post -Body $bodyUser -ContentType "application/json"
$res1 | Out-File -Append $mdFile
"`r`n**Registering 'demoadmin' (ROLE_ADMIN):**" | Out-File -Append $mdFile
$bodyAdmin = @{ username="demoadmin"; password="password123"; roles=@("admin") } | ConvertTo-Json
$res2 = Invoke-RestMethod -Uri "http://localhost:8085/api/auth/register" -Method Post -Body $bodyAdmin -ContentType "application/json"
$res2 | Out-File -Append $mdFile

"`r`n### 3. Authenticating and Generating JWT Tokens`r`n" | Out-File -Append $mdFile

"**Logging in 'demouser':**" | Out-File -Append $mdFile
$loginUser = @{ username="demouser"; password="password123" } | ConvertTo-Json
$jwtUserRes = Invoke-RestMethod -Uri "http://localhost:8085/api/auth/login" -Method Post -Body $loginUser -ContentType "application/json"
$jwtUserRes | ConvertTo-Json | Out-File -Append $mdFile
$userToken = $jwtUserRes.token

"`r`n**Logging in 'demoadmin':**" | Out-File -Append $mdFile
$loginAdmin = @{ username="demoadmin"; password="password123" } | ConvertTo-Json
$jwtAdminRes = Invoke-RestMethod -Uri "http://localhost:8085/api/auth/login" -Method Post -Body $loginAdmin -ContentType "application/json"
$jwtAdminRes | ConvertTo-Json | Out-File -Append $mdFile
$adminToken = $jwtAdminRes.token

"`r`n### 4. Testing Role-Based Access Control (RBAC) Endpoints`r`n" | Out-File -Append $mdFile

"**Testing Public Endpoint (/api/test/all):**" | Out-File -Append $mdFile
$resAll = Invoke-RestMethod -Uri "http://localhost:8085/api/test/all" -Method Get
$resAll | Out-File -Append $mdFile

"`r`n**Testing Protected User Endpoint as ROLE_USER (/api/test/user):**" | Out-File -Append $mdFile
$resUser = Invoke-RestMethod -Uri "http://localhost:8085/api/test/user" -Method Get -Headers @{Authorization="Bearer $userToken"}
$resUser | Out-File -Append $mdFile

"`r`n**Testing Protected Admin Endpoint as ROLE_ADMIN (/api/test/admin):**" | Out-File -Append $mdFile
$resAdmin = Invoke-RestMethod -Uri "http://localhost:8085/api/test/admin" -Method Get -Headers @{Authorization="Bearer $adminToken"}
$resAdmin | Out-File -Append $mdFile

"`r`n**Testing Protected Admin Endpoint as ROLE_USER (Should Fail/Unauthorized access):**" | Out-File -Append $mdFile
try {
    Invoke-RestMethod -Uri "http://localhost:8085/api/test/admin" -Method Get -Headers @{Authorization="Bearer $userToken"}
} catch {
    $_.Exception.Message | Out-File -Append $mdFile
}

"### 5. Shutting down application" | Out-File -Append $mdFile
Stop-Process -Id $appProcess.Id -Force
"Application shutdown successful.`r`n" | Out-File -Append $mdFile
