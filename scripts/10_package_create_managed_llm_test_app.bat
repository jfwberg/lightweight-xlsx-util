REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=devHubAlias
SET packageName=Lightweight - XLSX to LLM Util
SET packageDescription=A set of XLSX to LLM (flow) Utilities to compliment the Lightweight - XLSX Util
SET packageType=Managed
SET packagePath=force-app/xlsx_to_llm
SET definitionFile=config/project-package-def.json

REM Package Config
SET packageId=0HoP300000001ovKAA
SET packageVersionId=04tP3000001ouBJIAY

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
