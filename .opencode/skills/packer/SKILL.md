---
name: packer
description: HashiCorp Packer - infrastructure as code for creating machine images. Use when building AMIs, Docker images, or VM images with Packer HCL templates.
---

# Packer Agent Skill

Agent has access to local Packer documentation.

## When to Use

- Building machine images (AMI, Docker, GCP, Azure, etc.)
- Writing Packer HCL templates
- Debugging builder configurations
- Working with provisioners (Shell, Ansible, Chef, etc.)
- Configuring communicators (SSH, WinRM)

## Topics Available

- Builders (Amazon, Google, Azure, Docker, etc.)
- Provisioners (Shell, Ansible, Puppet, etc.)
- Post-processors (Docker push, Vagrant, etc.)
- Commands (build, validate, inspect, etc.)
- Configuration syntax and best practices

## Examples

```
User: Create a Packer template for AWS Ubuntu AMI
→ Agent reads contents/builders/amazon for reference
→ Generates working HCL template
```