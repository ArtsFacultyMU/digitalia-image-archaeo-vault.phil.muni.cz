<p align="left">
  <img src="https://webcentrum.muni.cz/media/3830724/seda_eosc-safespace-15.png" alt="EOSC CZ Logo" height="150">
</p>

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

- [ ] Rewrite gitlab cli to github action (or get access to gitlab) - what registry should the built image be published to?

- [ ] Which Kubernetes will the prototype run in?

- [ ] Include all modules used all across Digitalia in composer files - replicate what we did with Ansible?

- [ ] Test local development and merging of features

- [ ] Fix HTTP vs HTTPs issue

- [ ] Test data init with migrations

- [ ] smoother startup with less fuss?

- [ ] test deployment

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
---
This project output was developed within the [EOSC CZ](https://www.eosc.cz/projekty/narodni-podpora-pro-eosc) initiative throught the project **National Repository Platform for Research Data** (CZ.02.01.01/00/23_014/0008787) funded by Operational program Jan Amos Comenius (OP JAC) of the Ministry of Education, Youth and Sports of the Czech Republic (MEYS).

For more information, please contact us at: info@eosc.cz

---

<p align="left">
  <img src="https://webcentrum.muni.cz/media/3830728/seda_eu-msmt_eng-safespace.png" alt="EU and MŠMT Logos" height="150">
</p>
