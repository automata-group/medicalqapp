$src = "C:\Users\HP\Downloads\medical Q with AI\frontend\build\windows\x64\runner\Release"
$dest = "C:\Users\HP\Downloads\medical Q with AI\MedicalQBank_Windows_Client"
$zip = "C:\Users\HP\Downloads\medical Q with AI\MedicalQBank_Windows_Client.zip"

Write-Host "1. Cleaning previous output..."
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
if (Test-Path $zip) { Remove-Item -Force $zip }

Write-Host "2. Copying release files..."
New-Item -ItemType Directory -Path $dest | Out-Null
Copy-Item -Path "$src\*" -Destination $dest -Recurse

Write-Host "3. Creating friendly executable copy..."
Copy-Item -Path "$dest\frontend.exe" -Destination "$dest\MedicalQBank.exe"

Write-Host "4. Adding instructions..."
$readme = @"
==================================================
  تطبيق بنك الأسئلة والمحاكاة الطبية - Medical QBank
  نسخة أجهزة الكمبيوتر المحمول والمكتبي (Windows Laptop / Desktop)
==================================================

طريقة التشغيل:
1. انقر نقراً مزدوجاً على ملف: MedicalQBank.exe (أو frontend.exe).
2. سيبدأ البرنامج بالعمل فوراً وبسرعة دون الحاجة لأي تثبيت أو برامج مساعدة.

ملاحظات هامة:
- يرجى الحفاظ على وجود كافة الملفات والمجلدات المرفقة في نفس المجلد ليعمل البرنامج بسلاسة.
- التطبيق متصل تلقائياً بالسيرفر السحابي للوصول إلى كافة التخصصات والأسئلة ومزامنة المحفوظات واختبارات المحاكاة.
==================================================
"@
[System.IO.File]::WriteAllText("$dest\README_ابدأ_من_هنا.txt", $readme, [System.Text.Encoding]::UTF8)

Write-Host "5. Compressing to ZIP..."
Compress-Archive -Path "$dest\*" -DestinationPath $zip -CompressionLevel Optimal

Write-Host "6. Done!"
Get-Item $zip | Select-Object FullName, Length, LastWriteTime
