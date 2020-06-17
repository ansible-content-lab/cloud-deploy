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

<img src="images/tower_project.jpg" alt="Tower Project"
	title="Tower Project" width="500" />

I have elected to create a custom Python virtual environment that supports Python3. While this is not necessary for an Ansible Tower installation on Centos 8/RHEL 8 (which only comes with Python3), you can set up a custom Python virtual environent per [these instructions](https://docs.ansible.com/ansible-tower/latest/html/upgrade-migration-guide/virtualenv.html) (See section 4.1).



## Cloud Provider Credentials

Under Resources --> Projects, create a new set of credentials of the appropriate type. The example below, is for AWS programmatic keys, which you can generate in the AWS console:

<img src="images/cloud_credentials.jpg" alt="Cloud Credentials"
	title="Cloud Credentials" width="500" />

Of course, you must ensure that programmatic credentials you generate are for a user (or service account) that has permissions to create the cloud resources this demo generates.

Lastly, Ansible Tower automatically encrypts any secrets, which in the case of AWS is the *Secret Key*. Ansible Tower users (with appropriate permissions) can use the credential without knowing its contents.


## Job Templates

Once you have the Project and Credential set up, you can now move to setting up the individual Job Templates that will do the work against your cloud environment. Below is a description of each Job Template, and its required parameters. In general, you can expect a Job Template to look similar to this picture:

<img src="images/tower_job_template.jpg" alt="Tower Job Template"
	title="Tower Job Template" width="500" />

# Test Job Template

Description:

| Parameter | Value |
|-----|-----|
| Name  | Backup network configurations  |
|  Job Type |  Run |
|  Inventory |  Workshop Inventory |
|  Project |  Workshop Project |
|  Playbook |  network_backup.yml |
|  Credential |  Workshop Credential |

## Next Steps

- Go back to the first page of instructions: [Governing Self-Service Cloud Provisioning](../README.md)
- Continue to the next step: [Setting up the Ansible Tower Workflow](tower_workflow.md)
