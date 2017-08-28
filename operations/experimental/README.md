# cf-deployment experimental operations
"Experimental" ops-files represent configurations
that we expect to promote to blessed configuration eventually,
meaning that,
once the configurations have been sufficiently validated,
they will become part of cf-deployment.yml
and the ops-files will be removed.

Here's an (alphabetical) summary:
- `operations/experimental/bits-service.yml` - adds the [bits-service](https://github.com/cloudfoundry-incubator/bits-service)
  job and enables it in the cloud-controller. It also requires one of
  `bits-service-{local,webdav,s3}.yml` from the same directory. For S3,
  `use-s3-blobstore.yml` is also required.
