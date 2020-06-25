# Preparing Ansible Tower Project and Cloud Credentials

Once Ansible Tower is deployed, you need to do some initial setup in order to ingest playbooks and cloud credentials and make them available for use.


<!-- # Table Of Contents
- [Software Requirements](#requirements)
- [Variables](#variables)
  * [default-vars.yml](#default-variables)
  * [linux_users.yml](#linux-users)
- [Credentials](#credentials)
  * [gmail_creds.yml](#gmail-credentials)
  * [redhat-activation-key.yml](#redhat-activation-key)
  * [snow_creds.yml](#servicenow-credentials)
  * [tower_creds.yml](#tower-credentials)
  * [vault_creds.yml](#hashicorp-vault-credentials) -->

## Ansible Tower Project

Under Resources --> Projects, create a new Project with the following attributes:

<img src="images/tower_project.png" alt="Tower Project"
	title="Tower Project" width="800" />

| Parameter | Value |
|-----|-----|
| Name  | Deploy Cloud Applications  |
|  Organization |  Default |
|  SCM Type |  Git |
|  SCM URL |  https://github.com/michaelford85/cloud-deploy.git |
|  Clean |  Checkmark |

I have elected to create a custom Python virtual environment that supports Python3. While this is not necessary for an Ansible Tower installation on Centos 8/RHEL 8 (which only comes with Python3), you can set up a custom Python virtual environment per [these instructions](https://docs.ansible.com/ansible-tower/latest/html/upgrade-migration-guide/virtualenv.html) (See section 4.1).



## Cloud Provider Credentials

Under Resources --> Projects, create a new set of credentials of the appropriate type. The example below, is for AWS programmatic keys, which you can generate in the AWS console:

<img src="images/aws_credentials.jpg" alt="AWS Credentials"
	title="AWS Credentials" width="800" />

| Parameter | Value |
|-----|-----|
| Name  | Ansible Tiger Team AWS Programmatic Keys  |
|  Organization |  Default |
|  Credential Type |  Amazon Web Services |
|  Access Key |  `AWS Access Key` |
|  Secret Key |  `AWS Secret Key` |

And now for the GCP Programmatic Key:

<img src="images/gcp_credentials.jpg" alt="GCP Credentials"
	title="GCP Credentials" width="800" />

| Parameter | Value |
|-----|-----|
| Name  | GCP Project Credentials  |
|  Organization |  Default |
|  Credential Type |  Google Compute Engine |
|  Service Account JSON File |  `service account json file` |

In the case of GCP, you need not populate the **Service Account Email Address**, **Project**, and **RSA Private Key** fields. In your GCP Project, create a service account, and generate your key file. This file will contain all relevant information - when setting up your Tower GCP credential, pointing to the key file will automatically populate all this information.

Of course, you must ensure that programmatic credentials you generate are for a user (or service account) that has permissions to create the cloud resources this demo generates.

Lastly, Ansible Tower automatically encrypts any secrets. Ansible Tower users (with appropriate permissions) can use the credential without knowing its contents.

## Job Templates

Once you have the Project and Credential set up, you can now move to setting up the individual Job Templates that will do the work against your cloud environment. Below is a description of each Job Template, and its required parameters. In general, you can expect a Job Template to look similar to this picture:

<img src="images/tower_job_template.jpg" alt="Tower Job Template"
	title="Tower Job Template" width="500" />

### Open ServiceNow Change Request and wait for Approval

**Description:** if `from_snow` is true, a ServiceNow Change Request is opened, and an email with an approval request link is sent to the approval group (for this demo, the recipient email is hardcoded). The playbook will wait until the Change Request has been approved, or will time out. If `from_snow` is false, this playbook will do nothing, which helps if you choose to start the resulting Workflow Template from Ansible Tower and not ServiceNow.

| Parameter | Value |
|-----|-----|
| Name  | Open ServiceNow Change Request and wait for Approval  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `snow-cr-open-and-wait.yml` |
|  Credential |  `ansible-vault password` |

### Provision Cloud resources

**Description:** This provisions all networking resources (private cloud, subnet, internet gateway) with a hardcoded RFC1918 IP subnet and adds metadata for identification and cleanup purposes.

| Parameter | Value |
|-----|-----|
| Name  | Provision Cloud resources  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `provision_resources.yml` |
|  Credential |  `ansible-vault password`, `AWS Programmatic Key`, `GCP Programmatic Key` |

#### Extra Variables
```
---
#general
cloud_provider: gcp

#AWS
ec2_region: us-east-1
ec2_wait: yes
ec2_vpc_subnet: "192.168.0.0/28"
ec2_vpc_cidr: "192.168.0.0/24"

#GCP
gcp_region: us-central1
gcp_vpc_subnet: 192.168.0.0/28
```

### Provision Cloud Linux Instances

**Description:** Provisions public/private SSH Key pair, and adds the private key as an Ansible Tower credential called **Cloud Demo Instances Key**. Deploys the requested number of RHEL8 instances into the previously created subnet, plus an additional instance to host the Hashicorp vault secrets engine.

| Parameter | Value |
|-----|-----|
| Name  | Provision Cloud Linux Instances  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `provision_servers_tower.yml` |
|  Credential |  `ansible-vault password`, `AWS Programmatic Key`, `GCP Programmatic Key` |

#### Extra Variables
```
---
#general
cloud_provider: gcp
instance_size: small

#AWS
ec2_region: us-east-1
ec2_wait: yes
ec2_vpc_subnet: "192.168.0.0/28"
ec2_vpc_cidr: "192.168.0.0/24"

#GCP
gcp_region: us-central1
gcp_vpc_subnet: 192.168.0.0/28
```

### Teardown Cloud Linux Resources

**Description:** This tears down all networking resources (private cloud, subnet, internet gateway), indicated by the identifying metadata.

| Parameter | Value |
|-----|-----|
| Name  | Teardown Cloud Linux Resources  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `teardown_resources.yml` |
|  Credential |  `AWS Programmatic Key`, `GCP Programmatic Key` |

### Teardown Cloud Linux Instances

**Description:** This tears down all Linux instances, indicated by the identifying metadata.

| Parameter | Value |
|-----|-----|
| Name  | Teardown Cloud Linux Resources  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `teardown_servers_tower.yml` |
|  Credential |  `AWS Programmatic Key`, `GCP Programmatic Key` |

### Install Docker Engine on Linux Instances

**Description:** Installs Docker Engine on the additional Linux instance deployed.

| Parameter | Value |
|-----|-----|
| Name  | Install Docker Engine on Linux Instances  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `install-docker-engine.yml` |
|  Credential |  `ansible-vault password`, `Cloud Demo Instances Key` |


### Install/configure secrets engine

**Description:** Deploys a dev Hashicorp vault container from the Dockerhub image. Sets a root token from the vault_creds.yml file, variable name `vault_root_token`.

| Parameter | Value |
|-----|-----|
| Name  | Install/configure secrets engine  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `run-vault.yml` |
|  Credential |  `ansible-vault password`, `Cloud Demo Instances Key` |

### Initialize Linux Instances

**Description:** Performs the following functions on the requested RHEL 8 instances, plus the additional instance hosting the secrets engine:
- Waits for SSH connection to be available
- Registers with Red Hat Subscription Manager

| Parameter | Value |
|-----|-----|
| Name  | Initialize Linux Instances  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `initialize-instances.yml` |
|  Credential |  `ansible-vault password`, `Cloud Demo Instances Key` |


### Provision RHEL8 on Linux Instances

**Description:** Performs the following functions on the requested RHEL 8 instances:
- Registers with Red Hat Insights
- Updates all packages and installs Apache Webserver
- Deploys a dynamically generated index.html page

| Parameter | Value |
|-----|-----|
| Name  | Provision RHEL8 on Linux Instances  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `provision_rhel8.yml` |
|  Credential |  `ansible-vault password`, `Cloud Demo Instances Key` |

### Add RHEL8 users to Cloud Instances

**Description:** Creates a key-value secrets engine for vault, and adds all users/private keys to the secrets engine. The private keys are base64 encoded. Adds all users to the RHEL8 servers, gives them privilege escalation without a password required, and forces them to create a password upon first login.

| Parameter | Value |
|-----|-----|
| Name  | Add RHEL8 users to Cloud Instances  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `add-rhel8-users.yml` |
|  Credential |  `ansible-vault password`, `Cloud Demo Instances Key` |

### Update ServiceNow Change Request

**Description:** Updates the state of the ServiceNow Change Request, removes the CR artifact file if the state is changed to *closed* or *cancelled*.

| Parameter | Value |
|-----|-----|
| Name  | Update ServiceNow Change Request  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `snow-cr-update.yml` |
|  Credential |  `ansible-vault password` |

#### Extra Variables (check the box marked `PROMPT ON LAUNCH`)
```
close_state: 7
close_code: "unsuccessful"
close_notes: "Canceled by the requester"
```

### Send SNOW success email

**Description:** Sends an email to the requester if the ServiceNow Change Request is closed successfully.

| Parameter | Value |
|-----|-----|
| Name  | Send SNOW success email  |
|  Job Type |  Run |
|  Inventory |  Demo Inventory |
|  Project |  Deploy Cloud Applications |
|  Playbook |  `snow-cr-email.yml` |
|  Credential |  `ansible-vault password` |

#### Extra Variables
```
from_snow: no
```

## Next Steps

- Go back to the first page of instructions: [Governing Self-Service Cloud Provisioning](../README.md)
- Continue to the next step: [Setting up the Ansible Tower Workflow](tower_workflow.md)
