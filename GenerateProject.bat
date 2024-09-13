@echo off
:: Check for arg 1, if not, ask for project name
if "%1"=="" (
    set /p project=Enter the project name: 
) else (
    set project=%1
)

if not exist %project% (
    echo Creating project "%project%"
    mkdir %project%
)

if exist templates/main.template.odin (
    :: Check if the main.odin already exists, we don't want to overwrite the main file of a user
    if not exist %project%\%project%.odin (
        copy templates\main.template.odin %project%\%project%.odin
    ) else (
        echo %project%.odin already detected, not copying template over
    )
) else (
    echo Error: main.template.odin is missing
    pause
    exit /b
)

if exist templates/Windows.template.bat (
    if not exist %project%/RunWindows.bat copy templates\Windows.template.bat %project%\RunWindows.bat
    if not exist %project%/BuildWindows.bat copy templates\Windows.template.bat %project%\BuildWindows.bat

    powershell -Command "(Get-Content '%project%/RunWindows.bat') -replace '<project_name>', '%project%' | Set-Content '%project%/RunWindows.bat'"
    powershell -Command "(Get-Content '%project%/RunWindows.bat') -replace '<build_type>', 'run' | Set-Content '%project%/RunWindows.bat'"

    powershell -Command "(Get-Content '%project%/BuildWindows.bat') -replace '<project_name>', '%project%' | Set-Content '%project%/BuildWindows.bat'"
    powershell -Command "(Get-Content '%project%/BuildWindows.bat') -replace '<build_type>', 'build' | Set-Content '%project%/BuildWindows.bat'"
) else (
    echo Error: Windows.template.bat is missing
    pause
    exit /b
)

pause
