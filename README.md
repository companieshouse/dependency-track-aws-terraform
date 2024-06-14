# dependency-track-aws-terraform

Creates deployment of [Dependency Track](https://dependencytrack.org/) to AWS.
The deployment is managed by Companies House Concourse.

## Overview

Dependency Track is an application developed by OWASP for keeping a track of
vulnerabilities within the applications we develop. It analyses SBOM files to
look through all dependencies and then highlights any that are insecure
allowing Service Owners to understand the security of their services and be
able to prioritise accordingly.

The deployment looks like the below (some things like Security Groups are
ommitted.)

![Deployed AWS resources and network diagram](./assets/dependency-track-aws-terraform.png "Deployed AWS Resources")

The terraform is deployed using Companies House Concourse.

## SSO Configuration

SSO Is configured in both the API and Frontend via the environment variables.
This configuration is stored as secrets within the vault and read into the
applications via SSM Parameter Store. There is an application registration
within Azure AD corresponding to Dependency Track which is configured
[according to Dependency Track instructions.](https://docs.dependencytrack.org/getting-started/openidconnect-configuration/#azure-active-directory-app-registration)
We have also configured it to only send the relevant groups since there
is the
[following issue with Dependency Track](https://github.com/DependencyTrack/dependency-track/issues/2150)
which means it cannot handle a large number of Groups. This means that should
different groups need to be setup they will also need to be registered with the
application registration in Azure AD.

### Configuring SSO permissions

To configure SSO there is a little bit of manual configuration to map the AD
groups to Dependency Track permissions.

#### Mapping an Azure AD Group to a Dependency Track Team

1. If the team does not exist in Dependency Track, this needs to be created
2. Within Azure AD the Group needs to be created and then added to the Azure AD
  Application registration. (Raise a Service Now ticket)
3. From Azure AD copy the group ID (known as the `Object Id`)
4. Within Dependency Track, under Access Management, Click on
  `OpenID Connect Groups` and then click `Create Group` Group name is the
  ID copied in the former step and then select the team this group should be
  assuming in Dependency Track.

## Maintenance instructions

[Can be found on Confluence.](https://companieshouse.atlassian.net/wiki/spaces/DEV/pages/4601348098/Maintaining+Dependency+Track)

## Populating Dependency Track

### Using script: [populate-dependency-track](./bin/populate-dependency-track)

The script iterates over a list of repositories provided in a CSV file defining
the repository name and language. It will then clone the repository locally
before running the Concourse task to generate the SBOM and send to Dependency
Track.

**Example usage:**

```sh
$ cat ./repos
overseas-entities-api,java
overseas-entitites-web,node

$ ./bin/populate-dependency-track -t <target> ./repos
...

```

**Display help:**

```sh
$ ./bin/populate-dependency-track -h
./bin/populate-dependency-track
...
```
