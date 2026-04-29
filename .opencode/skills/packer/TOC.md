# Packer Documentation Contents

## Available Documentation

- [Builders](contents/builders/) - Creating machine images for different platforms
- [Provisioners](contents/provisioners/) - Installing/configuring software on images  
- [Post-processors](contents/post-processors/) - Processing images after build
- [Commands](contents/commands/) - Packer CLI commands
- [Communicators](contents/communicators/) - SSH/WinRM configuration
- [Templates](contents/templates/) - HCL template syntax

## Quick Reference

```bash
packer build template.pkr.hcl    # Build image
packer validate template.pkr.hcl  # Validate template
packer inspect template.pkr.hcl  # Show structure
```

## Topics

- AWS AMI building
- Google Cloud images
- Azure VM images
- Docker containers
- VMware/Fusion
- Provisioner configuration
- Variable usage
- Functions and expressions