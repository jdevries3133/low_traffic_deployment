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
The whole Kubernetes deployment is managed by this module, so there's not a
lot of room for extending this module if you want to expose other services
to the container.

For now, **two replicas of each application container will run.** There is no
auto-scaling or replica count argument.

Applications for where I use this module include:

- [empacadmusic.org](https://empacadmusic.org)
- [songmakergallery.com](https://songmakergallery.com)
- [classfast.app](https://classfast.app)
- [jackdevries.com](https://jackdevries.com)
- [katetell.com](https://katetell.com)

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

## Startup Probe

This config will, by default, perform a startup probe to the root route of the
application server. This is configurable through some terraform variables
(`startup_probe_path`, `readiness_timeout`). One thing that is not configurable
is that the hostname on the readiness probe request will be the internal IP
address of the pod. Some web application frameworks, like Django, include an
`ALLOWED_HOSTS` setting where you explicitly whitelist specific hostnames for
improved security, but neglecting to allow requests to the pod IP address will
cause the startup probe to fail.

There are a few workaround options, which balance security and complexity
differently.

| Workaround                                                                      | Security Implications                                                                     | Complexity Implications                                                         |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| enable requests from any host                                                   | completely undermines security that host whitelisting provides                            | quite simple in most web app frameworks                                         |
| enable requests from your expected host and the pod's own IP with `hostname -i` | allowing any direct connection from inside the cluster still undermines security somewhat | requires more application code to get the hostname                              |
| point the request to a special path for readiness                               | anyone can hit this path as long as it doesn't expose a DOS vulnerability; good           | requires non-trivial work, and a special route that has unique middleware rules |
| don't use a readiness probe                                                     | quite simple!                                                                             | might cause downtime during deployments, requires you to fork this config & DIY |
| go on vacation 🌴                                                               | nonexistent website can't be breached                                                     | live a simpler life                                                             |

Overall, you'll have to choose the option that works best for you.

## Demo App

A Django-based demo app is at `./demo`.

## Changelog

### 1.0.0

`readiness_probe` was removed and changed to `startup_probe`, which is what I
was aiming for in the first place. But I'll take an excuse to move into the
land of 1.0! This module is pretty stable and I've been using it across several
apps for a while now.
