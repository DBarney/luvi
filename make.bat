@ECHO off

for /f %%i in ('git describe') do set LUVI_TAG=%%i
IF NOT "x%1" == "x" GOTO :%1

GOTO :build

:static
ECHO "Building static"
cmake -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithZLIB=ON -DWithSharedZLIB=OFF -H. -Bbuild
GOTO :end

:static64
ECHO "Building static64"
cmake -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithZLIB=ON -DWithSharedZLIB=OFF -H. -Bbuild  -G"Visual Studio 12 2013 Win64"
GOTO :end

:tiny
ECHO "Building tiny"
cmake -H. -Bbuild
GOTO :end

:tiny64
ECHO "Building tiny64"
cmake -H. -Bbuild -G"Visual Studio 12 2013 Win64"
GOTO :end

:build
IF NOT EXIST build CALL Make.bat large
cmake --build build --config Release -- /maxcpucount
COPY build\Release\luvi.exe .
GOTO :end

:test
IF NOT EXIST luvi.exe CALL Make.bat
SET LUVI_APP=samples\test.app
luvi.exe
SET LUVI_TARGET=test.exe
luvi.exe
SET "LUVI_APP="
SET "LUVI_TARGET="
test.exe
DEL /Q test.exe
GOTO :end

:winsvc
IF NOT EXIST luvi.exe CALL Make.bat
DEL /Q winsvc.exe
SET LUVI_APP=samples\winsvc.app
SET LUVI_TARGET=winsvc.exe
luvi.exe
SET "LUVI_APP="
SET "LUVI_TARGET="
GOTO :end

:repl
IF NOT EXIST luvi.exe CALL Make.bat
DEL /Q repl.exe
SET LUVI_APP=samples\repl.app
SET LUVI_TARGET=repl.exe
luvi.exe
SET "LUVI_APP="
SET "LUVI_TARGET="
GOTO :end


:clean
IF EXIST build RMDIR /S /Q build
IF EXIST luvi.exe DEL /F /Q luvi.exe
GOTO :end

:publish
ECHO "Building all versions"
git submodule update --init --recursive
CALL make.bat clean
CALL make.bat tiny64
CALL make.bat test
GOTO :end

:reset
git submodule update --init --recursive
git clean -f -d
git checkout .
GOTO :end

:publish-tiny
CALL make.bat reset
CALL make.bat tiny64
CALL make.bat test
github-release upload --user luvit --repo luvi --tag %LUVI_TAG% --file luvi.exe --name luvi-tiny-Windows-amd64.exe
GOTO :end

:publish-static
CALL make.bat reset
CALL make.bat static64
CALL make.bat test
github-release upload --user luvit --repo luvi --tag %LUVI_TAG% --file luvi.exe --name luvi-static-Windows-amd64.exe
GOTO :end

:end
