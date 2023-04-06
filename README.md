# docker-swarm-infrastructure
Terraform script to deploy 3-node machine to MS Azure Subcription.

- Clone this repo and just do a `cd docker-swarm-infrastructure`
- Open terminal at this path and run `az login` to login to your azure subscription.
- Once you've logged in, it's time to execute `terraform apply`

> **Note** <br>
> I have opened only SSH, HTTP, HTTPS and other ports for communication in docker swarm. If you're going to open any other port, let's say 5001 then you'll have to add the security rule in network security group.

