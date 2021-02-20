# Terraform IaC DevOps

## Intro
**Name:** Chris Wiederspan  
**Role:** Microsoft Azure App Dev Specialist  
**Email:** chwieder@microsoft.com

## Prerequisites

### Setup a Service Principal for use with AKS

Based on [this guidance](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-service-principal), we will start by setting up a Service Principal that we'll use when creating an Azure AKS cluster.

`az login`  
`az ad sp create-for-rbac --name <YOUR_SP_NAME> --skip-assignment`

You'll want to make a copy of the results, specifically the appId and password, as shown below.

![Credential screenshot](/assets/service-principal-creds.png)
