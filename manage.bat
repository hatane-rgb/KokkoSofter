@echo off
echo KokkoSofter Management Commands (Windows)
echo ==========================================

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="dev-setup" goto dev-setup
if "%1"=="run" goto run
if "%1"=="migrate" goto migrate
if "%1"=="superuser" goto superuser
if "%1"=="static" goto static
if "%1"=="test" goto test
if "%1"=="check" goto check
if "%1"=="shell" goto shell
if "%1"=="clean" goto clean
if "%1"=="start" goto start
goto help

:help
echo Available commands:
echo   dev-setup    Setup development environment
echo   run          Start development server
echo   migrate      Run database migrations
echo   superuser    Create superuser
echo   static       Collect static files
echo   test         Run tests
echo   check        Run Django system check
echo   shell        Start Django shell
echo   clean        Clean temporary files
echo   start        Quick start development
echo.
echo Usage: manage.bat dev-setup
goto end

:dev-setup
echo Setting up development environment...
python -m venv ..\venv
..\venv\Scripts\pip install --upgrade pip
..\venv\Scripts\pip install -r ..\requirements.txt
if not exist ..\.env copy ..\.env.example ..\.env
..\venv\Scripts\python manage.py makemigrations
..\venv\Scripts\python manage.py migrate
..\venv\Scripts\python manage.py collectstatic --noinput
echo Development environment setup complete!
goto end

:run
echo Starting development server...
..\venv\Scripts\python manage.py runserver 0.0.0.0:8000
goto end

:migrate
echo Running migrations...
..\venv\Scripts\python manage.py makemigrations
..\venv\Scripts\python manage.py migrate
echo Migration complete!
goto end

:superuser
echo Creating superuser...
..\venv\Scripts\python manage.py createsuperuser
goto end

:static
echo Collecting static files...
..\venv\Scripts\python manage.py collectstatic --noinput
echo Static files collection complete!
goto end

:test
echo Running tests...
..\venv\Scripts\python manage.py test
goto end

:check
echo Running system check...
..\venv\Scripts\python manage.py check
goto end

:shell
echo Starting Django shell...
..\venv\Scripts\python manage.py shell
goto end

:clean
echo Cleaning temporary files...
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"
del /s /q *.pyc 2>nul
del /s /q *.pyo 2>nul
echo Cleanup complete!
goto end

:start
echo Starting KokkoSofter...
if not exist ..\venv call :dev-setup
call :run
goto end

:end
