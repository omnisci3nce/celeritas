@echo off
set project="<project_name>"
if not exist "build" mkdir "build"
odin <build_type> %project%.odin -out:build/%project%.exe -file
pause