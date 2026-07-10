@echo off
echo ========================================================
echo CineFile Web Sürümü Derleniyor ve GitHub'a Yükleniyor...
echo ========================================================
echo.
echo Adim 1: Proje web icin derleniyor...
call flutter build web --release --base-href "/CineFile/"
if %errorlevel% neq 0 (
    echo.
    echo HATA: Derleme basarisiz oldu!
    pause
    exit /b %errorlevel%
)

echo.
echo Adim 2: Yeni versiyon GitHub'a gonderiliyor (push)...
cd build\web
call git init
call git config user.name "CineFile Deploy"
call git config user.email "deploy@cinefile.local"
call git checkout -b main
call git add .
call git commit -m "otomatik deploy"
call git push --force https://github.com/Alp3rol/CineFile.git main:gh-pages
cd ..\..

echo.
echo ========================================================
echo ISLEM TAMAMLANDI! 
echo Siteniz birkac dakika icinde yeni haliyle yayinda olacak.
echo ========================================================
pause
