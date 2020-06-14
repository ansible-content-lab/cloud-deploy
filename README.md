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
- [Lab Setup](#lab-setup)
  - [One Time Setup](#one-time-setup)
  - [Setup (per workshop)](#setup-per-workshop)
  - [Accessing student documentation and slides](#Accessing-student-documentation-and-slides)
- [Lab Teardown](#aws-teardown)
- [Demos](#demos)
- [FAQ](../docs/faq.md)
- [More info on what is happening](#more-info-on-what-is-happening)
- [Remote Desktop](#remote-desktop)
- [Getting Help](#getting-help)

# Requirements

- Ansible Tower 3.7 or later: [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- Ansible Tower License: [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- ServiceNow Developer Instance: [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi).
- Programmatic Cloud Credentials
  - This demo begins with AWS, but will be expanding to include Azure and GCP.

# Variables

# default-vars

The [default variables file](vars/default-vars.yml) contains the basic variables needed to set up the cloud infrastructure. In some cases (such as VPC subnets), these variables are hard-coded for simplicity's sake; in production this would change.
- `***working_dir***`: Starting with Ansible Tower 3.6, Job and Workflow Templates are executed in a temporary directory. When running a Workflow Template, any artifact created in an individual Job Template will not persist by default. This is where the `working_dir` variable comes into play. `working_dir` defines a directory where artifacts get placed for the life of the workflow. It is important that this directory is made writable by Ansible Tower, and this can be done in the Ansible Tower settings: ![Tower Job Path Settings](images/tower_writable_paths.jpg)
- `ec2_region`:
- `ec2_prefix`:
- `application`:
- `num_instances`:
- `ec2_image_id`:
- `ec2_wait`:
- `ec2_vpc_subnet`:
- `ec2_vpc_cidr`:
- `ec2_root_volume_size`:
- `from_snow`:
- `instance_username`:

# linux_users

Description of linux users
<!---
The goal of this repository is to demonstrate self-service provisioning of cloud infrastructure and applications using [Ansible Automation Platform](https://www.ansible.com/products/automation-platform) on the backend, and [ServiceNow](https://www.servicenow.com/now-platform.html) to start the process.

Provisioning infrastructure (bare-metal, cloud VMs, serverless) with Ansible allows you to seamlessly transition into configuration management, orchestration and application deployment using the same simple, human readable, automation language. Taking this one step further, running Ansible Automation Platform enables integration with your existing platforms to power self-service automation for people of various skill levels - domain expert, junior architect, operations specialist, etc.

Here you will find Ansible playbooks to automate the deployment of linux servers and applications on AWS (we can of course use similar playbooks against other major cloud providers and on-premise orchestrators). These playbooks are meant to be primarily for demonstrations, showing the "art of the possible" and ephemeral in nature. Additionally, these playbooks are meant to be run as part of an Ansible Tower Workflow rather than run independently.

**Prerequisites**:

- [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi). --->
