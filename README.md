# Low Traffic Deployment Terraform Module

Almost all of my web apps that I am prototyping or that otherwise don't get a
lot of traffic have _exactly_ the same needs. I'm pretty religious about
PostgreSQL as a data backend, and although I move between different application
backends (Django, Remix, Next.JS, etc.), every app basically boils down to:

- 1 application container
- 1 PostgreSQL database

As such, this terraform module is an extremely generic and constrained IaC
config that suits these applications. There are only three required inputs:

- app name
- domain
- container (i.e. `jdevries3133/jackdevries.com:0.0.4`)

Other arguments, outputs, and other functionality might be added in the future,
but for the average generic application, I know that this will do the trick,
and it's better to keep things simple.

For now, **two replicas of each application container will run.**

Applications for which this module would be used by me include:

- `empacad.org`
- `reset.empacad.org`
- `songmakergallery.com`
- `classfast.app`

## Use Case

I have a kubernetes cluster with three nodes running in my home. This module
deploys to that kubernetes cluster (or any cluster). For more details on
my cluster, see [homelab_cluster](https://github.com/jdevries3133/homelab_cluster)

## PostgreSQL Connection

PostgreSQL connection details will be injected into the container as the
following environment variables:

- `POSTGRESQL_DB`
- `POSTGRESQL_USERNAME`
- `POSTGRESQL_PASSWORD`
- `POSTGRESQL_HOST`

The port will always be the standard Postgres port of `5432`.
