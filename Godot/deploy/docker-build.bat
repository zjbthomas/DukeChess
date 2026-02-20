@echo off
echo Building dukechess-godot-web Docker image...
docker build -f Docker/Dockerfile -t dukechess-godot-web .
echo Done.
pause