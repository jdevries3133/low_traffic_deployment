# Low Traffic Deployment Terraform Module

Almost all of my web apps that I am prototyping or that otherwise don't get a
lot of traffic have _exactly_ the same needs. I'm pretty religious about
PostgreSQL as a data backend, and although I move between different application
backends (Django, Remix, Next.JS, etc.), every app basically boils down to:

- 1 application container
- 1 PostgreSQL database

As such, this terraform module is an IaC config that suits these applications.
There are only three required inputs:

- app name
- domain
- container (fully qualified name i.e. `jdevries3133/jackdevries.com:0.0.4`)

Additional optional arguments allow apps to grow a bit along with this config,
but ultimately this is a good config for prototyping a postgres-backed app.
The whole kubernetes deployment is managed by this module, so there's not a
lot of room for extending this module if you want to expose other services
to the container.

For now, **two replicas of each application container will run.** There is no
auto-scaling or replica count argument.

Applications for which this module would be used by me include:

- [empacadmusic.org](https://empacadmusic.org)
- [songmakergallery.com](https://songmakergallery.com)
- [classfast.app](https://classfast.app)

## My Cluster

Learn all about my cluster by checking out my
[homelab_cluster](https://github.com/jdevries3133/homelab_cluster)
repository.

## PostgreSQL Connection

PostgreSQL connection details will be injected into the container as the
following environment variables:

- `POSTGRES_DB`
- `POSTGRES_USERNAME`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `DATABASE_URL`

The port will always be the standard Postgres port of `5432`.

`DATABASE_URL` is a composition of the database name, username, password, and
host, and it's used by some ORMs like Prisma.

## Demo App

A Django-based demo app is at `./demo`.
