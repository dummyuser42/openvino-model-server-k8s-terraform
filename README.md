# openvino-model-server-k8s-terraform
Repo for deploying Kubernetes cluster via Terraform as well as deploying and hosting a OpenVINO Model Server on it.

## OpenVINO Model Server Overview

The Intel OpenVINO toolkit is a set of tools and libraries for optimizing deep learning models for inference on Intel hardware, including CPUs, GPUs, and FPGAs, enabling efficient and high-performance deployment of models for a wide range of use cases.

OpenVINO Model Server is an open-source deep learning inference server designed to deploy machine learning models trained using the Intel OpenVINO toolkit. The server provides an API that enables clients to send inference requests to the server, which runs the model and returns the results. It supports a variety of input and output formats, including TensorFlow, ONNX, and Caffe models. The OpenVINO Model Server can be used to deploy models to edge devices, cloud environments, or on-premises servers, making it a flexible and versatile solution for deploying machine learning models at scale. Additionally, it provides features such as model versioning, model management, and monitoring capabilities, making it easy to manage and scale large deployments of machine learning models.

## Repo Overview

The repo defines the infrastructure as code for deploying a Kubernetes cluster for hosting an OpenVINO Model Server using Terraform. It uses the OpenVINO Model Server for hosting the [Inception model](https://docs.openvino.ai/latest/omz_models_model_inception_resnet_v2_tf.html) used for image classification. 

It includes a helm chart as well as values required for deploying the model. The OpenVINO Model Server is exposed over the internet via a load balancer service. 


## Deploying the OpenVINO Model Server on a Kubernetes Cluster

### Pre-requisites
 
A few different technologies are used to deploy the OpenVINO Model Server. Information on how to set these up can be found below:

- Azure Infrastructure - the repo assumes access to an Azure Subscription with either Owner or Contributor to be able to create a new resource group. The Application Developer role is required for creating a Service Principal. It assumes the Azure CLI is [installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) on the developer machine

- Terraform - Terraform is used for the Infrastructure Deployment. This repo is using version 1.4.5 of Terraform. More information on installing Terraform can be found [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli). Information on configuring Terraform with Azure can be found [here](https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure)

- `kubectl` is used for interacting with Kubernetes cluster once deployed. Install guide: https://pwittrock.github.io/docs/tasks/tools/install-kubectl/

- `helm` is used for deploying the OpenVINO model server onto the cluster. Install guide: https://helm.sh/docs/intro/install/

- In order to download, convert and test the deployed model, a few Python packages are required. These can be found in the requirements file and can be installed into a virtual environment. At the time of deployment, Python 3.10.4 was used. 


### Step by step guide

#### 1. Creating an Azure Service Principal

Create an Azure Service Principal using the following Azure CLI command:

`az ad sp create-for-rbac --skip-assignment`

Once created, populate the a `terraform.tfstate` file with the given values for the `service_principal_client_id` and `service_principal_client_secret`. Note to ensure this file is part of the `.gitignore`

### 2. Download and convert model

- Create, activate and install requirements into Python Virtual Environment

- Download the model using the OpenVINO Model downloader `omz_downloader --name inception-resnet-v2-tf`

- Convert model into an OpenVINO IR (Intermediate Representation) format `omz_converter --name inception-resnet-v2-tf`

- The result should include three files in working directory `public/inception-resnet-v2-tf/FP16`: `inception-resnet-v2-tf.bin`, `inception-resnet-v2-tf.mapping` and `inception-resnet-v2-tf.xml`

### 3. Create AKS Cluster and Storage Account

Initialise Terraform files: 
`terraform init`

Preview what will be deployed into Azure:
`terraform plan`

Apply the changes into the Azure Subscription:
`terraform apply`

This should create an AKS cluster, Storage Account, Container and Blobs for the models

### 4. Configure kubectl

Configure `kubectl` to point to the newly created AKS cluster
`az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

### 5. Deploy OpenVINO Model Server

Get the connection string from the Azure Storage Account and set it as an environment variable. Here we assume the environment variable is called `STORAGE_ACCOUNT_CONNECTION_STRING`

The OpenVINO Model Server should now be ready to be deployed using the helm chart included in the repo. Note that this is obtained from the [openvinotoolkit GitHub](https://github.com/openvinotoolkit/operator/blob/main/helm-charts/ovms/README.md)

`helm upgrade -f open_vino_model_server/values.yaml ovms-app open_vino_model_server --set azure_storage_connection_string=$STORAGE_ACCOUNT_CONNECTION_STRING`

Once run, check the resouces are created. This should include a deployment for the model server and a Cluster IP service exposing two endpoints for gRPC and REST on ports 8080 and 8081 respectively

### 6. Deploy Load Balancer

To expose the model server over the internet, a load balancer can be used. This can be created using the deployment manifest using:
`kubectl apply -f load-balancer.yaml`

Get the public IP address of the load balancer using a command like `kubectl get services -o wide`

### 7. Run Acceptance Tests to Validate

Add the public IP address of the load balancer into the acceptance tests, pip install pytest into your environment and run the tests using 
`python -m pytest tests/acceptance` to validate that the model has been deployed on the OpenVINO Model server successfully

Note that the acceptance tests give an example of how a client could be built to call the model from within a Python application

### References:
- OpenVINO Model Server overview: https://docs.openvino.ai/latest/ovms_what_is_openvino_model_server.html
- Hashicorp demo on deploying an AKS cluster via Terraform: https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks
- OpenVINO Model Server via Helm Chart: https://github.com/openvinotoolkit/operator/tree/main/helm-charts/ovms
- Inception Resnet V2: https://docs.openvino.ai/latest/omz_models_model_inception_resnet_v2_tf.html