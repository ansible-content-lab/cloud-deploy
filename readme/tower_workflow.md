# Setting up the Ansible Tower Workflow

After creating the individual Ansible Tower Job Templates, you can put them together in a Workflow Template for end-to-end deployment.

Workflow Templates are valuable for automation teams as they allow domain experts to maintain control of their individual responsibilities (they can own the playbook that governs their part of the architecture) while providing the ability to deploy entire services holistically. Workflow Templates also allow for error handling and atomic changes.

In this demo, you will create two workflows; one for *provisioning* your cloud workload, and another for *tearing it down*. these instructions will walk you through setting up the workflow and the parameters for each part of the workflow.

**Cloud workload provisioning Workflow Template:**

<img src="images/provision_workflow_full.png" alt="Tower Project"
	title="Tower Project" width="1000" />

I will break this into two smaller images later in the documentation.

**Cloud workload teardown Workflow Template:**

<img src="images/teardown_workflow.png" alt="Tower Project"
	title="Tower Project" width="800" />

In the Workflow Templates above, each box represents an invocation of one of the Job Templates we defined in the previous section. The lines represent contracts between those Job Templates, and are color-coded accordingly:
- A **blue** line means that the Job Template to the right of it will always run.
- A **green** line means that the Job Template to the right of it will only run of the Job Template to the left of it, ran successfully.
- A **red** line means that the Job Template to the right of it will only run of the Job Template to the left of it, failed.

In cases where a Job Template has two green lines leading to it, like so:
<img src="images/provision_workflow_two_conditions.jpg" alt="Tower Project"
	title="Tower Project" width="500" />

Set the `Convergence` parameter of the resulting Workflow Node (in this case, *Send SNOW success email*) to **ALL**. This way, *both* of the previous Job Templates must succeed in order to proceed upon the success path, which is the desired behavior.

# Provisioner Workflow Template

First, let's walk through the provisioner Workflow Template.

You can set up the Workflow Template by navigating to Resources --> Templates, and clicking on the green + button, selecting to create a Workflow Template.

For the provisioner template, fill out the fields as follows:

<img src="images/workflow_parameters.png" alt="Workflow Parameters"
	title="Workflow Parameters" width="800" />

  | Parameter | Value |
  |-----|-----|
  | Name  | Provision Cloud Linux Servers with Users  |
  | Organization  | Default  |
  |  Inventory | Demo Inventory |

#### Extra Variables (check the box marked `PROMPT ON LAUNCH`)
  ```
	---
  from_snow: no
  ```

For starting this Workflow Template from Ansible Tower, the Workflow requires three parameters, specified via survey, asking for the number of RHEL 8 instances the user wishes to deploy, how big they need to be, and which cloud provider to provision them into.

The survey will look like this:

<img src="images/tower_survey.png" alt="Tower Project"
	title="Tower Survey" width="500" />

Here are the details required for both questions:

| Parameter | Value |
|-----|-----|
| Prompt  | How many instances should be spun up?  |
| Description  | Please select no more than 10.  |
|  Answer Variable Name | `num_instances` |
|  Answer Type |  Integer |
|  Minimum |  `1` |
|  Maximum |  `10` |
|  Default Answer |  `3` |
|  Required |  Checkmark |

| Parameter | Value |
|-----|-----|
| Prompt  | What size instance should be selected?  |
|  Answer Variable Name | `instance_size` |
|  Answer Type |  Multiple Choice (single select) |
|  Multiple Choice Options |  `small`, `medium`, `large` |
|  Default Answer |  `medium` |
|  Required |  Checkmark |

| Parameter | Value |
|-----|-----|
| Prompt  | Which Cloud provider to provision into?  |
|  Answer Variable Name | `cloud_provider` |
|  Answer Type |  Multiple Choice (single select) |
|  Multiple Choice Options |  `aws`, `gcp` |
|  Required |  Checkmark |

When setting up the Workflow Template visualizer, you can select the next step by clicking on the START button:

<img src="images/workflow_start.jpg" alt="Workflow Start"
	title="Workflow Start" width="800" />

From there, you can choose the Job Template, when it runs (`Always` for the first selection, `Always`, `On Success`, or `On Failure` for subsequent Job Templates), convergence (`All` or `Any`), and any prompts if necessary. Each Job Template will give these details.

<img src="images/provision_workflow_start.png" alt="Tower Project"
	title="Tower Project" width="800" />

## 1) Open ServiceNow Change Request and wait for Approval

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Open ServiceNow Change Request and wait for Approval |
|  Run |  Always |
|  Convergence |  Any |

## 2) Provision Cloud Resources

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Provision Cloud Resources |
|  Run |  On Success |
|  Convergence |  Any |

## 3) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  On Failure |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 4
close_code: unsuccessful
close_notes: 'Canceled by Ansible: Approval not given within allotted time.'
```

## 4) Provision Cloud Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Provision Cloud Linux Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 5) Teardown Cloud Linux Resources

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Teardown Cloud Linux Resources |
|  Run |  On Failure |
|  Convergence |  Any |

## 6) AWS Application Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Inventory Sync  |
|  Inventory Name |  AWS Application Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 7) GCP Application Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Inventory Sync  |
|  Inventory Name |  GCP Application Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 8) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  Always |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 4
close_code: unsuccessful
close_notes: 'Canceled by Ansible: Linux instances not created successfully.'
```

## 9) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  Always |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 4
close_code: unsuccessful
close_notes: 'Canceled by Ansible: Problem when trying to provision network resources.'
```

## 10) Initialize Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Initialize Linux Instances |
|  Run |  On Success |
|  Convergence |  All |


  <img src="images/provision_workflow_end.png" alt="Tower Project"
  	title="Tower Project" width="800" />

## 11) Install Docker Engine on Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Install Docker Engine on Linux Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 12) Install/configure secrets engine

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Install/configure secrets engine |
|  Run |  On Success |
|  Convergence |  Any |

## 13) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  On Failure |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 4
close_code: unsuccessful
close_notes: 'Canceled by Ansible: Error when trying to install Docker.'
```



## 14) Provision RHEL8 on Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Provision RHEL8 on Linux Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 15) Add RHEL8 users to Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Add RHEL8 users to Linux Instances |
|  Run |  On Success |
|  Convergence |  Any |

## 16) Send SNOW success email

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Send SNOW success email |
|  Run |  On Success |
|  Convergence |  All |

## 17) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  On Failure |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 4
close_code: unsuccessful
close_notes: 'Canceled by Ansible: Error in provisioning RHEL8 application and users.'
```

## 18) Update ServiceNow Change Request

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Update ServiceNow Change Request |
|  Run |  On Success |
|  Convergence |  Any |

**PROMPT:**
```
---
close_state: 3
close_code: successful
close_notes: Linux Instances deployed successfully!
```

# Teardown Workflow Template

Finally, let's walk through the teardown Workflow Template:

<img src="images/teardown_workflow_parameters.png" alt="Teardown Workflow Parameters"
	title="Teardown Workflow Parameters" width="800" />

  | Parameter | Value |
  |-----|-----|
  | Name  | Teardown Cloud Linux Application, Instances and Resources  |
  | Organization  | Default  |
  |  Inventory | Demo Inventory |

For starting this Workflow Template from Ansible Tower, the Workflow requires one parameter, specified via survey, asking which cloud provider to look into for the resources to tear down.

The survey will look like this:

<img src="images/teardown_survey.png" alt="Teardown Survey"
		title="Teardown Survey" width="500" />

| Parameter | Value |
|-----|-----|
| Prompt  | Which Cloud provider to perform teardown in?  |
|  Answer Variable Name | `cloud_provider` |
|  Answer Type |  Multiple Choice (single select) |
|  Multiple Choice Options |  `aws`, `gcp` |
|  Required |  Checkmark |

<img src="images/teardown_workflow_numbered.png" alt="Teardown Workflow Template" title="Teardown Workflow Template" width="800" />

## 1) Teardown Cloud Linux Instances

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Teardown Cloud Linux Instances |
|  Run |  Always |
|  Convergence |  Any |

## 2) Teardown Cloud Linux Resources

| Parameter | Value |
|-----|-----|
| Node Type  | Template  |
|  Template Name |  Teardown Cloud Linux Resources |
|  Run |  On Success |
|  Convergence |  Any |

Now, you're ready to run deploy your cloud resources.


## Next Steps

- Go back to the first page of instructions: [Governing Self-Service Cloud Provisioning](../README.md)
- Continue to the next step: [The Payoff: Deploying Your Cloud Workload](workflow_kickoff.md)
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
