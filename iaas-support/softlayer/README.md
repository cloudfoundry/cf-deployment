# Deploy Cloud Foundry on a Softlayer Bosh-Lite Director

To deploy Cloud Foundry on a Softlayer VM with a Bosh-Lite director, you will need to follow the default Bosh-Lite instructions with one addition. As the director is public the `system_domain` property cannot be `bosh-lite.com`. You will need to replace the `system_domain` with your own either static or dynamic DNS domain (which should point to the director VM). It is required to deploy Cloud Foundry with the [Bosh-DNS](https://github.com/cloudfoundry/bosh-dns-release) addon and add the alias for you `system_domain`, to resolve the custom domain.
The updated `create-env` command is the following:

```
bosh -e <your-bosh-alias> deploy -d cf cf-deployment/cf-deployment.yml \
    --vars-store deployment-vars.yml \
    -o cf-deployment/operations/bosh-lite.yml \
    -o cf-deployment/operations/experimental/use-bosh-dns.yml \
    -o cf-deployment/iaas-support/softlayer/add-system-domain-dns-alias.yml \
    -v system_domain=<your-domain>
```  
