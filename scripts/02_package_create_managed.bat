REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=devHubAlias
SET packageName=Lightweight - XLSX Util
SET packageDescription=A lightweight library to build and parse Excel(XLSX) files
SET packageType=Managed
SET packagePath=force-app/package
SET definitionFile=config/project-package-def.json

REM Package Config
SET packageId=0HoP300000000jBKAQ
SET packageVersionId=04tP3000001or6zIAA

REM Create package
sf package create --name "%packageName%" --description "%packageDescription%" --package-type "%packageType%" --path "%packagePath%" --target-dev-hub %devHub%

REM Create package version
sf package version create --package "%packageName%"  --target-dev-hub "%devHub%" --code-coverage --installation-key-bypass --wait 30 --definition-file "%definitionFile%"

REM Delete package
sf package:delete -p %packageId% --target-dev-hub %devHub% --no-prompt

REM Delete package version
sf package:version:delete -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Promote package version
sf package:version:promote -p %packageVersionId% --target-dev-hub %devHub% --no-prompt
