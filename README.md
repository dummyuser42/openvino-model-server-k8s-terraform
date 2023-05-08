# openvino-model-server-k8s-terraform
Repo for deploying Kubernetes cluster via Terraform as well as deploying and hosting a OpenVINO Model Server on it


### Deploying OpenVino Model 

helm upgrade -f open_vino_model_server/values.yaml ovms-app open_vino_model_server --set azure_storage_connection_string=$STORAGE_ACCOUNT_CONNECTION_STRING
