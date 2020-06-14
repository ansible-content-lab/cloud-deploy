# Providing Governance to Self-Service Infrastructure Provisioning in the Cloud


Cloud providers such as Amazon Web Services, Google Cloud Platform, and Microsoft Azure have developed mature, feature-rich platforms that allow organizations to deploy innovative applications and services. In most cases, this high level of control is welcome - however in certain cases, simple self-service cloud provisioning is preferred:
- Silo breakdown: Automation of infrastructure/application provisioning typically involves multiple teams (network, security, OS, database) preparing the underlying mechanisms
- Speed of delivery:
- faster remediation

At the end of the day, organizations can use self-service to allow end-users to create on-demand, ephemeral workloads in a way that's simple to understand. This repository is an example of just that, using this interface:

![ServiceNow Provisioning Catalog Item](images/snow_cloud_catalog.png)

To provision this infrastructure:

<!--- #TODO replace this with the Cloud Infrastructure--->
![Placeholder](images/snow_cloud_catalog.png)

<!---
The goal of this repository is to demonstrate self-service provisioning of cloud infrastructure and applications using [Ansible Automation Platform](https://www.ansible.com/products/automation-platform) on the backend, and [ServiceNow](https://www.servicenow.com/now-platform.html) to start the process.

Provisioning infrastructure (bare-metal, cloud VMs, serverless) with Ansible allows you to seamlessly transition into configuration management, orchestration and application deployment using the same simple, human readable, automation language. Taking this one step further, running Ansible Automation Platform enables integration with your existing platforms to power self-service automation for people of various skill levels - domain expert, junior architect, operations specialist, etc.

Here you will find Ansible playbooks to automate the deployment of linux servers and applications on AWS (we can of course use similar playbooks against other major cloud providers and on-premise orchestrators). These playbooks are meant to be primarily for demonstrations, showing the "art of the possible" and ephemeral in nature. Additionally, these playbooks are meant to be run as part of an Ansible Tower Workflow rather than run independently.

**Prerequisites**:

- [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi). --->
