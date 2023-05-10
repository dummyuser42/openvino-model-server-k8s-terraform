# openvino-model-server-k8s-terraform
Repo for deploying Kubernetes cluster via Terraform as well as deploying and hosting a OpenVINO Model Server on it


### Deploying OpenVino Model 

Configure AKS credentials
`az aks get-credentials --resource-group mneu-rg-dev-modelserving --name mneu-aks-dev-modelserving`
helm upgrade -f open_vino_model_server/values.yaml ovms-app open_vino_model_server --set azure_storage_connection_string=$STORAGE_ACCOUNT_CONNECTION_STRING


### References:
- OpenVINO Model Server via Helm Chart: https://github.com/openvinotoolkit/operator/tree/main/helm-charts/ovms
- Inception Resnet V2: https://docs.openvino.ai/latest/omz_models_model_inception_resnet_v2_tf.html