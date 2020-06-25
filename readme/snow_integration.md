# Bonus: Deploying Your Cloud Workload via ServiceNow

Although this demo now works in Ansible Tower, many end-users do not want to learn a new interface in order to perform their tasks. This is not a problem at all for Ansible Tower, which provides a RESTful API to allow 3rd-party platforms to kick of jobs programmatically. As ServiceNow is widely used in organizations, these instructions walk you through setting up ServiceNow to start this demonstration in Ansible Tower.

If you sign up for a ServiceNow Developer account, ServiceNow offers a free instance that can be used for replicating and testing this functionality. You can visit [this link](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi) to obtain ServiceNow Developer Instance.

## Notes
- These instructions assume that there is no MID-Server for ServiceNow, and that the ServiceNow developer instance and Ansible Tower can talk to each other directly over the public internet.
- This has been tested with:
  - Ansible Tower 3.6, 3.7
  - ServiceNow Orlando Release

## Dependencies:

### Python libraries

```bash
pip3 install pysnow
```
This python package must be installed in the virtual environment that is used to run playbooks that communicate with ServiceNow

### Collections

```bash
ansible-galaxy collection install servicenow.servicenow
```
This collection is already present in this repository and the above is the command that was run to retrieve it.

## Instructions

### Preparing Ansible Tower

#### 1)
In Ansible Tower, navigate to Applications on the left side of the screen. Click the green plus button on the right, which will present you with a Create Application dialog screen. Fill in the following fields:
| Parameter | Value |
|-----|-----|
| Name  | Descriptive name of the application that will contact Ansible Tower  |
|  Organization |  `Default` |
|  Authorization Grant Type |  Authorization code |
|  Redirect URIs |  `https://<snow_instance_id>.service-now.com/oauth_redirect.do` |
|  Client Type |  `Confidential` |

<img src="../images/create_application.png" alt="Tower Create Application" title="Tower Create Application" width="1000" />

#### 2)
Click the green **Save** button on the right, at which point a window will pop up, presenting you with the Client ID and Client Secret needed for ServiceNow to make API calls into Ansible Tower. This will only be presented **ONCE**, so capture these values for later use.

<img src="../images/application_secrets.png" alt="Tower Application Secrets" title="Tower Application Secrets" width="1000" />

#### 3)
Next, navigate to Settings-->System on the left side of the screen. You’ll want to toggle the Allow External Users to Create Oauth2 Tokens option to on. Click the green Save button to commit the change.

<img src="../images/tower_settings.png" alt="Tower Settings" title="Tower Settings" width="1000" />

#### 4)
The Orlando release of the ServiceNow developer instance does not seem to allow for the self-signed certificate provided by Ansible Tower. We need to equip our Tower instance with a certificate from a trusted Certificate Authority. The easiest way to accomplish this to run the Certbot ACME client in order to generate a certificate from LetsEncrypt (instructions can be found [here](https://letsencrypt.org/getting-started/)). It is important to place the contents of the certificate you generate, followed by the LetsEncrypt intermediate certificate (starting on a new line) at location Tower places its self-signed certificate, /etc/tower/tower.cert. The LetsEncrypt intermediate certificate can be found [here](https://letsencrypt.org/certificates/). Be sure to restart the nginx service on your Tower server after updating the certificate.

### Preparing ServiceNow

####5)
Moving over to ServiceNow, Navigate to System Definition-->Certificates. This will take you to a screen of all the certificates Service Now uses. Click on the blue New button, and fill in these details:
| Parameter | Value |
|-----|-----|
| Name  | Descriptive name of the certificate  |
|  Format |  `PEM` |
|  Type |  `Trust Store Cert` |
|  PEM Certificate |  The certificate to authenticate against Ansible Tower with. Use the certificate you just generated on your Tower server, located at /etc/tower/tower.cert. Copy the contents of this file (EXCLUDE the intermediate certificate) into the field in ServiceNow.
Click the Submit button at the bottom. |
|  Client Type |  `Confidential` |

Click the **Submit** button at the bottom.

### Testing connectivity between ServiceNow and Ansible Tower

### Creating a ServiceNow Catalog Item to Launch an Ansible Tower Job Template

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
  * [vault_creds.yml](#hashicorp-vault-credentials)

## Requirements -->
