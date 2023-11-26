# please run az login before run this script 
read -p "Docker Registry name: " dockerRegistryName
read -p "Version: " version
read -p "Resource group name:" resourceGroupName
read -p "Location: " location
echo "build docker image...\n"

imageName=$dockerRegistryName/webchat:$version

docker build -f ../Dockerfile -t $imageName ..

docker push $imageName

    az group create --name webchat-rg  --location eastus

az storage account create \
    --name tomwebchatstg \
    --resource-group webchat-rg \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2

az storage share create \
    --account-name tomwebchatstg \
    --account-key $(az storage account keys list --account-name tomwebchatstg --resource-group webchat-rg --query "[0].value" -o tsv) \
    --name webchatdb

az container create --resource-group webchat-rg --file aci.yaml
