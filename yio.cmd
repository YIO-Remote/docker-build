@echo OFF
REM Wrapper build script for yio-remote/build Docker image
REM https://github.com/YIO-Remote/documentation/wiki
REM
REM Environment variables:
REM Either define them in your environment (Control Panel, System Properties, Advanced: Environment Variables)
REM or define them in your current cmd session:
REM SET YIO_BUILD_OUTPUT=d:/projects/yio/build-output
REM 
REM Mandatory environment variables:
REM - YIO_BUILD_OUTPUT: defines the mapped output directory for the binary artefacts. 
REM 
REM Optional environment variables:
REM - YIO_BUILD_SOURCE: defines the mapped source directory of the projects.
REM   If not defined a Docker Volume named `yio-projects` will be used.
REM 

SETLOCAL
SET YIO_PROJECTS_SOURCE=yio-projects
SET YIO_DOCKER_IMG=yioremote/remote-os-build

IF NOT DEFINED YIO_BUILD_OUTPUT (
	ECHO Environment variable YIO_BUILD_OUTPUT not defined!
	EXIT /B 3
)
IF NOT EXIST "%YIO_BUILD_OUTPUT%" (
    ECHO Output directory defined in 'YIO_BUILD_OUTPUT' doesn't exist: '%YIO_BUILD_OUTPUT%'
	EXIT /B 3
)

docker version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Docker is not running
	EXIT /B %ERRORLEVEL%
)

IF "%1" == "info" (
    ECHO Using docker image                   : %YIO_DOCKER_IMG%
	<nul set /p =Docker image version                 : 
	docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.version\"}}" %YIO_DOCKER_IMG%
	ECHO Storing build output in              : %YIO_BUILD_OUTPUT%
)

IF DEFINED YIO_BUILD_SOURCE (
	IF NOT EXIST "%YIO_BUILD_SOURCE%" (
		ECHO Source directory defined in 'YIO_BUILD_SOURCE' doesn't exist: '%YIO_BUILD_SOURCE%'
		EXIT /B 3
	) ELSE IF "%1" == "info" (
        ECHO Mounting projects from host directory: %YIO_BUILD_SOURCE%
	)
	SET YIO_PROJECTS_SOURCE=%YIO_BUILD_SOURCE%
) ELSE (
	IF "%1" == "info" (
        ECHO Using Docker Volume for projects     : %YIO_PROJECTS_SOURCE%
	)
	CALL :checkDockerVolume %YIO_PROJECTS_SOURCE%
	IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
)

CALL :checkDockerVolume yio-buildroot
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

docker run --rm -it -v %YIO_PROJECTS_SOURCE%:/yio-remote/src -v yio-buildroot:/yio-remote/buildroot -v "%YIO_BUILD_OUTPUT%":/yio-remote/target %YIO_DOCKER_IMG% %*
EXIT /B %ERRORLEVEL%

:checkDockerVolume
docker volume inspect %~1 >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Docker volume '%~1' doesn't exist: creating it...
	docker volume create %~1
)

EXIT /B %ERRORLEVEL%