# digitalia-image-archaeo-vault.phil.muni.cz

This is a Docker image for a test instance of the **ArchaeoVault** repository, an instance of the Islandora repository system. The repository is being created as a pilot repository to be integrated into the Czech National Repository Platform (NRP).

This is a fork of the docker image created by Marek Jaroš at CIT FF MU for Digitalia.

First a default instance is installed, then it is customized. Our customizations can be found in separate GitHub repositories, which are cloned to designated parts of the app and then applied if necessary.

# Getting started

```console
# build
docker build --network=host --pull -t archaeo-vault:latest .
# run pgsql
docker run --network=host -it -e POSTGRES_USER=drupal -e POSTGRES_PASSWORD=drupal postgres:17
# run drupal image w/ terminal
docker run --network=host -it archaeo-vault:latest bash
```

# TO DO

- [ ] Rewrite gitlab cli do github action (or get access to gitlab)

- [ ] Include all modules used all across Digitalia in composer files

- [ ] Test local development and merging of features

- [ ] Fix HTTP vs HTTPs issue

# Troubleshooting for MacOS/M1

`docker network create archaeo-net`
replace `--network=host` with `--network=archaeo-net`
add explicit port to expose on

```console
docker build --pull --platform=linux/amd64 -t archaeo-vault:latest .

docker run -d --name=pg --network=archaeo-net -e POSTGRES_USER=drupal -e POSTGRES_PASSWORD=drupal -p 5432:5432 postgres:17

docker run -d --name=archaeo-vault --platform=linux/amd64 --network=archaeo-net -it -p 8080:80 archaeo-vault:latest bash
```

access at: http://localhost:8080/
the site annoyingly redirects to https, you need to rewrite it to http after each page reload

when connecting islandora to db, instead of localhost enter pg, use postgres as name and drupal as login and password

select minimal installation profile

installs default islandora with digitalia modules (not enabled) but not config
"The staged configuration cannot be imported, because it originates from a different site than this site. You can only synchronize configuration between cloned instances of this site."

```console
drush config-set system.site uuid 86955ff9-1be3-40ad-84ae-414c65ae901c -y
```
