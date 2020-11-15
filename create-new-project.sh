#create new python profile and install flask
python3 -m venv venv
source venv/bin/activate
pip install flask

#create new app directory
mkdir ~/BestBikeApp
cd ~/BestBikeApp

#open VSCode
code application.py

#create application requirements
pip freeze > requirements.txt

#start web application to test
cd ~/BestBikeApp
export FLASK_APP=application.py
flask run

###

## deploy with az webapp up

#set vriables
APPNAME=$(az webapp list --query [0].name --output tsv)
APPRG=$(az webapp list --query [0].resourceGroup --output tsv)
APPPLAN=$(az appservice plan list --query [0].name --output tsv)
APPSKU=$(az appservice plan list --query [0].sku.name --output tsv)
APPLOCATION=$(az appservice plan list --query [0].location --output tsv)

#run az webapp up with appropriate values
cd ~/BestBikeApp
az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location "$APPLOCATION"

