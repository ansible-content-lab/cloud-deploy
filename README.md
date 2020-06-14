# Providing Governance to Self-Service Infrastructure Provisioning in the Cloud


Cloud providers have developed mature, feature-rich platforms that allow organizations to deploy innovative applications and services. In most cases, this high level of control is welcome - however in certain cases, simple self-service cloud provisioning is preferred:
- **Speed of Delivery:** Mature automation can be run by end-users with stripped-down options and less roadblocks, allowing business-critical applications/solutions to be delivered more quickly.
- **Silo breakdown:** Automation of infrastructure/application provisioning encourages multiple teams of domain experts (network, security, OS, database) to work together, preparing a holistic solution to a known problem.
- **Enables Innovation:** When common cloud workloads are automated and presented with self-service delivery, domain experts are free to focus on the innovative solutions they were hired to develop.

Ultimately, organizations can use self-service to allow end-users to create on-demand, ephemeral workloads in a way that's simple to understand. This repository is an example of just that, with the end-user using this interface:

![ServiceNow Provisioning Catalog Item](images/snow_cloud_catalog.png)

To provision this infrastructure:

<!--- #TODO replace this with the Cloud Infrastructure--->
![Placeholder](images/snow_cloud_catalog.png)

What the end user will not see, is the set of Ansible Tower playbooks, running as a Workflow Template, such as the one we see here:

![Cloud Provisioning Workflow](images/cloud_workflow.gif)

Let's walk through the Ansible playbooks in this repository to see how this is accomplished.
# Table Of Contents
- [Requirements](#requirements)
- [Variables](#variables)
  - [default-vars](#default-vars)
  - [linux_users](#linux_users)
- [Credentials](#credentials)
  - [gmail_creds](#gmail_creds)
  - [redhat-activation-key](#redhat-activation-key)
  - [snow_creds](#snow_creds)
  - [tower_creds](#tower_creds)
  - [Hashicorp vault Credentials](#Hashicorp-vault-Credentials)
<!---
- [Lab Setup](#lab-setup)
  - [One Time Setup](#one-time-setup)
  - [Setup (per workshop)](#setup-per-workshop)
  - [Accessing student documentation and slides](#Accessing-student-documentation-and-slides)
- [Lab Teardown](#aws-teardown)
- [Demos](#demos)
- [FAQ](../docs/faq.md)
- [More info on what is happening](#more-info-on-what-is-happening)
- [Remote Desktop](#remote-desktop)
- [Getting Help](#getting-help) --->

## Requirements

- Ansible Tower 3.7 or later: [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- Ansible Tower License: [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- ServiceNow Developer Instance: [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi).
- Programmatic Cloud Credentials
  - This demo begins with AWS, but will be expanding to include Azure and GCP.

# Variables

# default-vars

The [default variables file](vars/default-vars.yml) contains the basic variables needed to set up the cloud infrastructure. In some cases (such as VPC subnets), these variables are hard-coded for simplicity's sake; in production there would be logic to dynamically change the values.


- `working_dir`: Starting with Ansible Tower 3.6, Job and Workflow Templates are executed in a temporary directory. When running a Workflow Template, any artifact created in an individual Job Template will not persist by default. This is where the `working_dir` variable comes into play. `working_dir` defines a directory where artifacts are placed for the life of the workflow. It is important that this directory is made writable by Ansible Tower, and this can be done in the Ansible Tower settings: ![Tower Job Path Settings](images/tower_writable_paths.jpg)
- `ec2_region`: Dictates the AWS region in which all resources will be provisioned.
- `ec2_prefix`: The prefix that will appear in the names of all AWS resources (VPC, subnets, security groups, etc.) created in this demo.
- `application`: As this demo supports more applications, this variable will indicate which application was deployed. This value is used to mark newly created instances via AWS tags.
- `num_instances`: The number of linux instances to deploy. This value will be overridden by the one specified in the Ansible Tower Workflow Template.
- `ec2_image_id`: The AMI used to deploy linux. In the sample file, this is **RHEL 8**.
- `ec2_wait`: Determines whether to wait for the ec2 instance to reach its desired state before returning from creation.
- `ec2_vpc_subnet`: The IP Subnet assigned to the AWS subnet that is created.
- `ec2_vpc_cidr`: The IP Subnet assigned to the AWS VPC that is created.
- `ec2_root_volume_size`: The size of the Elastic Block Store volumes tied to the linux instances created, in GB.
- `from_snow`: This indicates whether or not the Workflow Template was called from ServiceNow, or Ansible Tower. When this value is `true`, a ServiceNow Change Request is created and modified/closed as the Workflow Template progresses.
- `instance_username`: The default username which is used to log into the newly created linux instances. For RHEL 8, this is **ec2-user**.

# linux_users

The [linux users](vars/linux_users.yml) contains a list of users to add to the provisioned linux instances. These users will have the ability to use privilege escalation, and also be forced to create a password when they first log in via SSH private key.

# Credentials

This demonstration requires credentials (in YAML format) in order to integrate with other platforms. The credential files in this repository are all encrypted with ansible-vault, and the ansible-vault credential is passed to every Job Template where any of the credentials are required. Each of these files must be present in order for this demonstration to work; the variables in each credential file are listed here:

# gmail_creds

This is to simulate a use case where an email is sent to the required approvers when a ServiceNow Change Request is made. the email address here is used to send an approval request.

In the case of a gmail using multi-factor authentication, the password has to be an application-specific password generated in your gmail security settings.

File format:
```
---
gmail_username: user@gmail.com
gmail_password: password
```

# redhat-activation-key

When provisioning RHEL instances, this activation key (generated at https://access.redhat.com) is used to subscribe instances using subscription-manager. Alternatively, you can elect to deploy non-RHEL linux instances (Centos is suggested).

File format:
```
---
rhactivationkey: the-activation-key
rhorg_id: "99999999"
```

# snow_creds

The credentials and name of developer instance used to kick off self-service of cloud provisioning via a Catalog item.

File format:
```
---
SNOW_USERNAME: admin
SNOW_PASSWORD: password
SNOW_INSTANCE: dev99999
```
# tower_creds

The url and credentials for the demo to populate Ansible Tower resources, such as the SSH private key generated from the cloud provider.

File format:
```
---
tower_url: https://ansible.tower.com
tower_user: admin
tower_pass: password
```

# vault_creds

As part of this demo, a Hashicorp vault container is created to store the user credentials externally. Instead of a randomly generated root token for login, you can select an easy-to-remember root token (this is of course for demo purposes, only).

File format:
```
---
vault_root_token: thetoken
```

<!---
The goal of this repository is to demonstrate self-service provisioning of cloud infrastructure and applications using [Ansible Automation Platform](https://www.ansible.com/products/automation-platform) on the backend, and [ServiceNow](https://www.servicenow.com/now-platform.html) to start the process.

Provisioning infrastructure (bare-metal, cloud VMs, serverless) with Ansible allows you to seamlessly transition into configuration management, orchestration and application deployment using the same simple, human readable, automation language. Taking this one step further, running Ansible Automation Platform enables integration with your existing platforms to power self-service automation for people of various skill levels - domain expert, junior architect, operations specialist, etc.

Here you will find Ansible playbooks to automate the deployment of linux servers and applications on AWS (we can of course use similar playbooks against other major cloud providers and on-premise orchestrators). These playbooks are meant to be primarily for demonstrations, showing the "art of the possible" and ephemeral in nature. Additionally, these playbooks are meant to be run as part of an Ansible Tower Workflow rather than run independently.

**Prerequisites**:

- [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi). --->
