# Self-Service Automation of Infrastructure and Linux Applications on Amazon Web Services with ServiceNow


The goal of this repository is to demonstrate self-service provisioning of cloud infrastructure and applications using [Ansible Automation Platform](https://www.ansible.com/products/automation-platform) on the backend, and [ServiceNow](https://www.servicenow.com/now-platform.html) to start the process.

Provisioning infrastructure (bare-metal, cloud VMs, serverless) with Ansible allows you to seamlessly transition into configuration management, orchestration and application deployment using the same simple, human readable, automation language. Taking this one step further, running Ansible Automation Platform enables integration with your existing platforms to power self-service automation for people of various skill levels - domain expert, junior architect, operations specialist, etc.

Here you will find Ansible playbooks to automate the deployment of linux servers and applications on AWS (we can of course use similar playbooks against other major cloud providers and on-premise orchestrators). These playbooks are meant to be primarily for demonstrations, showing the "art of the possible" and ephemeral in nature. Additionally, these playbooks are meant to be run as part of an Ansible Tower Workflow rather than run independently.

**Prerequisites**:

- [Ansible Tower 3.7+ installation Guide](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).
- [Ansible Tower 60-day trial license](https://www.redhat.com/en/technologies/management/ansible/try-it).
- [ServiceNow Developer Instance](https://developer.servicenow.com/dev.do#!/guide/orlando/now-platform/pdi-guide/obtaining-a-pdi).
