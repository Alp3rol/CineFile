@echo off
echo ========================================================
echo CineFile Web Sürümü Derleniyor ve GitHub'a Yükleniyor...
echo ========================================================
echo.
echo Adim 1: Proje web icin derleniyor...
REM --no-wasm-dry-run: Flutter varsayilan olarak, uygulamayi bir de WASM'a
REM derlenebiliyor mu diye kontrol eder. Bu ayri bir tam derleme gecisi ve
REM olculdu: dagitim basina ~22 saniye (toplamin ucte biri). Ciktiyi hic
REM etkilemiyor - bayrakli ve bayraksiz derlemelerin main.dart.js hash'leri
REM birebir ayni. WASM'a gecilirse bu bayrak kaldirilmali.
call flutter build web --release --no-wasm-dry-run --base-href "/CineFile/"
if %errorlevel% neq 0 (
    echo.
    echo HATA: Derleme basarisiz oldu!
    pause
    exit /b %errorlevel%
)

echo.
echo Adim 2: Yeni versiyon GitHub'a gonderiliyor (push)...
pushd build\web
call git init -q
call git config user.name "Alp3rol"
call git config user.email "alp3rol17@gmail.com"
REM -B, -b degil: dal zaten var oldugundan -b her calistirmada
REM "fatal: a branch named 'main' already exists" hatasi basiyordu.
call git checkout -q -B main
call git add .

set MSG=%~1
if "%MSG%"=="" (
    set /p MSG="Guncelleme aciklamasini girin (Bos birakilirsa 'otomatik deploy' yazilacak): "
)
if "%MSG%"=="" set MSG=otomatik deploy

call git commit -m "%MSG%"
call git push --force https://github.com/Alp3rol/CineFile.git main:gh-pages
REM Push sonucunu popd'den ONCE yakala: popd errorlevel'i sifirlar.
set PUSHRESULT=%errorlevel%
popd

if %PUSHRESULT% neq 0 (
    echo.
    echo ========================================================
    echo HATA: Push basarisiz oldu, site GUNCELLENMEDI!
    echo Yukaridaki git ciktisina bakin.
    echo ========================================================
    pause
    exit /b %PUSHRESULT%
)

echo.
echo ========================================================
echo ISLEM TAMAMLANDI!
echo Siteniz birkac dakika icinde yeni haliyle yayinda olacak.
echo ========================================================
REM pause yerine timeout: bir tusa basmani beklemiyor, 5 saniye sonra
REM kendi kapaniyor (herhangi bir tusla hemen gecilebilir). 2>nul, script
REM otomasyondan (stdin yonlendirilmis halde) cagrildiginda timeout'un
REM bastigi "Input redirection is not supported" hatasini gizler.
timeout /t 5 2>nul
