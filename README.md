# epoc-infrastructure

Manage Epoc GCP resources via Terraform. 

This configuration does not:

- set IAM roles or permissions
- enable services in GCP

## Decrypt keys and terraform state: 

`./decrypt-state-and-keys.sh`

## After changes made to GCP resources via terraform, encrypt state and keys:

`./encrypt-state-and-keys.sh`

### Creating GCP resources:

- Cd to "infra" dir:

`cd infra`

- First time: 

`terraform init`

- Select workspace:

`terraform workspace select [dev|prod]`

- Create/update GCP resources:

`terraform apply -var='environment=[dev|prod]'`

### Updating secrets to GCP from gopass

Secrets are stored in gopass -> to update secrets, update them to gopass first.

- Cd to "secrets" dir:

`cd secrets`

- Select appropriate terraform workspace:

`terraform select workspace [dev|prod]`

- Sync gopass

`gopass sync`

- Export secrets from gopass:

`source ./export-secrets.sh [dev|prod]`

- Create/update secrets in GCP secrets manager:

`terraform apply`



