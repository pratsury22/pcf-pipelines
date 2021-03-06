#!/bin/bash
set -eu

ROOT="${PWD}"

function delete-opsman() {
  source "${ROOT}/pcf-pipelines/functions/check_opsman_available.sh"

  OPSMAN_AVAILABLE=$(check_opsman_available "${OPSMAN_DOMAIN_OR_IP_ADDRESS}")
  if [[ ${OPSMAN_AVAILABLE} == "available" ]]; then
    om-linux \
      --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
      --skip-ssl-validation \
      --username ${OPSMAN_USERNAME} \
      --password ${OPSMAN_PASSWORD} \
      delete-installation
  fi
}

function delete-infrastructure() {
  echo "=============================================================================================="
  echo "Executing Terraform Destroy ...."
  echo "=============================================================================================="

  terraform destroy -force \
    -var "subscription_id=${AZURE_SUBSCRIPTION_ID}" \
    -var "client_id=${AZURE_SERVICE_PRINCIPAL_ID}" \
    -var "client_secret=${AZURE_SERVICE_PRINCIPAL_PASSWORD}" \
    -var "tenant_id=${AZURE_TENANT_ID}" \
    -var "location=dontcare" \
    -var "env_name=dontcare" \
    -var "env_short_name=dontcare" \
    -var "azure_terraform_vnet_cidr=dontcare" \
    -var "azure_terraform_subnet_infra_cidr=dontcare" \
    -var "azure_terraform_subnet_ert_cidr=dontcare" \
    -var "azure_terraform_subnet_services1_cidr=dontcare" \
    -var "azure_terraform_subnet_dynamic_services_cidr=dontcare" \
    -var "ert_subnet_id=dontcare" \
    -var "pcf_ert_domain=dontcare" \
    -var "pub_ip_pcf_lb=dontcare" \
    -var "pub_ip_id_pcf_lb=dontcare" \
    -var "pub_ip_tcp_lb=dontcare" \
    -var "pub_ip_id_tcp_lb=dontcare" \
    -var "priv_ip_mysql_lb=dontcare" \
    -var "pub_ip_ssh_proxy_lb=dontcare" \
    -var "pub_ip_id_ssh_proxy_lb=dontcare" \
    -var "pub_ip_opsman_vm=dontcare" \
    -var "pub_ip_id_opsman_vm=dontcare" \
    -var "pub_ip_jumpbox_vm=dontcare" \
    -var "pub_ip_id_jumpbox_vm=dontcare" \
    -var "subnet_infra_id=dontcare" \
    -var "ops_manager_image_uri=dontcare" \
    -var "vm_admin_username=dontcare" \
    -var "vm_admin_password=dontcare" \
    -var "vm_admin_public_key=dontcare" \
    -var "azure_multi_resgroup_network=dontcare" \
    -var "azure_multi_resgroup_pcf=dontcare" \
    -var "priv_ip_opsman_vm=dontcare" \
    -var "azure_account_name=dontcare" \
    -var "azure_buildpacks_container=dontcare" \
    -var "azure_droplets_container=dontcare" \
    -var "azure_packages_container=dontcare" \
    -var "azure_resources_container=dontcare" \
    -state "${ROOT}/terraform-state/terraform.tfstate" \
    -state-out "${ROOT}/terraform-state-output/terraform.tfstate" \
    "pcf-pipelines/install-pcf/azure/terraform/${AZURE_PCF_TERRAFORM_TEMPLATE}"
}

function main() {
  if [[ "${ARG_WIPE}" == "wipe" ]]; then
    echo "Wiping Environment...."
  else
    echo "Need Args [0]=wipe, anything else and I swear I'll exit and do nothing!!! "
    echo "Example: ./wipe-env.sh wipe ..."
    exit 0
  fi

  delete-opsman
  delete-infrastructure
}

main
