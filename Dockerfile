# Envars
ARG VERSION=6.4.2


# Islandora Drupal
FROM islandora/drupal:${VERSION}

ARG NAME=archaeo-vault
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG SITE_VERSION=1.10.0

RUN printf "Running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a).\n"

# Basic info
LABEL maintainer="Jan Adler <adler@phil.muni.cz>" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name=${NAME} \
    org.label-schema.description="ArchaeoVault" \
    org.label-schema.version=${VERSION} \
    org.label-schema.url="https://github.com/ArtsFacultyMU/digitalia-image-archaeo-vault.phil.muni.cz" \
    org.label-schema.usage="https://github.com/ArtsFacultyMU/digitalia-image-archaeo-vault.phil.muni.cz/blob/main/README.md" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.vcs-url=${VCS_URL} \
    org.label-schema.vendor="Masaryk University - Faculty of Arts" \
    org.label-schema.schema-version="1.0"

# Prepare environment
WORKDIR "/var/www"

COPY content/ /

# Repo branch variables (tags can also be used)
ARG BRANCH_GENERAL_THEME=v1.0.0
ARG BRANCH_THEME=v1.0.0
ARG BRANCH_CONF=v0.1.6-r4
ARG BRANCH_PATCHES=v1.0.2
ARG BRANCH_TOKEN=v1.0.0
ARG BRANCH_GENERAL_INCLUDES=v1.0.0
ARG BRANCH_ENTITY=v1.0.0
ARG BRANCH_FITS_GENERATOR=v1.0.0
ARG BRANCH_WORKBENCH_INGEST=v0.1.0
ARG BRANCH_DATASET_CCMM=v1.1.0
ARG BRANCH_DATASET_DOI=v1.1.0
ARG BRANCH_AUTOCOMPLETE_REMOTE=v1.0.0
ARG BRANCH_NFIELD_AGENT=v1.2.1
ARG BRANCH_CUSTOM_FIELD_TYPES=v0.1.0

# Install packages
RUN    apk -qq update \
    && apk -qq upgrade \
    && apk -qq add coreutils \
    && apk -qq add vim \
    && apk -qq add gettext-envsubst  \
    # Cleanup
    && rm -rf /var/cache/apk/* \
    # Composer will refuse to install to existing directory even when empty :-/
    && rmdir /var/www/drupal/web/libraries /var/www/drupal/web /var/www/drupal/config \
    && su nginx -s /bin/bash -c 'composer -q -n create-project islandora/islandora-starter-site:${SITE_VERSION} /var/www/drupal' \
    && su nginx -s /bin/bash -c 'rm -rf /var/www/drupal/config/sync/*' \
    # Synchronize ArchaeoVault configuration
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_CONF} https://github.com/ArtsFacultyMU/digitalia-config-archaeo-vault.phil.muni.cz.git /var/www/drupal/tmp_config' \
    && su nginx -s /bin/bash -c 'mv /var/www/drupal/tmp_config/configs/* /var/www/drupal/config/sync/' \
    && su nginx -s /bin/bash -c 'mv /var/www/drupal/tmp_config/composer* /var/www/drupal/' \
    # Patches
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_PATCHES} https://github.com/ArtsFacultyMU/digitalia-patches.git /var/www/drupal/patches' \
    # Init test data
    && su nginx -s /bin/bash -c 'mv /var/www/drupal/tmp_config/data /var/www/drupal/' \
    # Cleanup
    && su nginx -s /bin/bash -c 'rm -rf /var/www/drupal/tmp_config' \
    # Custom modules
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_TOKEN}               https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_token.git /var/www/drupal/web/modules/custom/digitalia_muni_token' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_GENERAL_INCLUDES}    https://github.com/ArtsFacultyMU/digitalia_module-digitalia_muni_general_includes.git /var/www/drupal/web/modules/custom/digitalia_muni_general_includes' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_ENTITY}              https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_entity.git /var/www/drupal/web/modules/custom/digitalia_muni_entity' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_FITS_GENERATOR}      https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_fits_generator.git /var/www/drupal/web/modules/custom/digitalia_muni_fits_generator' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_WORKBENCH_INGEST}    https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_workbench_ingest.git /var/www/drupal/web/modules/custom/digitalia_muni_workbench_ingest' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_DATASET_CCMM}        https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_dataset_ccmm.git /var/www/drupal/web/modules/custom/digitalia_muni_dataset_ccmm' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_DATASET_DOI}         https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_dataset_doi.git /var/www/drupal/web/modules/custom/digitalia_muni_dataset_doi' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_AUTOCOMPLETE_REMOTE} https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_autocomplete_remote.git /var/www/drupal/web/modules/custom/digitalia_muni_autocomplete_remote' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_NFIELD_AGENT}        https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_nfield_agent.git /var/www/drupal/web/modules/custom/digitalia_muni_nfield_agent' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_CUSTOM_FIELD_TYPES}  https://github.com/ArtsFacultyMU/digitalia-module-custom_field_types.git /var/www/drupal/web/modules/custom/digitalia_custom_field_types' \
    # Custom themes
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_GENERAL_THEME}       https://github.com/ArtsFacultyMU/digitalia-general-theme-muni_style.git /var/www/drupal/web/themes/custom/islandora_muni' \
    && su nginx -s /bin/bash -c 'git clone -q -b ${BRANCH_THEME}               https://github.com/ArtsFacultyMU/digitalia-theme-archaeo-vault.phil.muni.cz.git /var/www/drupal/web/themes/custom/islandora_muni/platform_specific' \
    # Modules
    && su nginx -s /bin/bash -c 'composer install -n -d /var/www/drupal'

#COPY templated_settings.php /var/www/drupal/web/sites/default/templated_settings.php
COPY additional-variables.conf.tmpl /etc/confd/templates/additional-variables.conf.tmpl
COPY additional-variables.conf.toml /etc/confd/conf.d/additional-variables.conf.toml

ENV \
    DRUPAL_DEFAULT_DOI_PASSWORD=NONE \
    DRUPAL_DEFAULT_RECAPTCHA_SITE_KEY=NONE \
    DRUPAL_DEFAULT_RECAPTCHA_SECRET_KEY=NONE \
    DRUPAL_DEFAULT_AAI_CLIENT_ID=NONE \
    DRUPAL_DEFAULT_AAI_CLIENT_SECRET=NONE \
    DRUPAL_DEFAULT_HANDLE_PRIVATE_KEY=NONE \
    DRUPAL_DEFAULT_CANTALOUPE_URL=NONE \
    DRUPAL_DEFAULT_GEOCODER_USER_AGENT=NONE \
    DRUPAL_DEFAULT_GEOCODER_REFERER=NONE

RUN   mv "/var/www/drupal" "/var/www/drupal.docker"

    #su nginx -s /bin/bash -c 'cd /var/www/drupal/web/sites/default/ && cat templated_settings.php | envsubst '${DRUPAL_DEFAULT_DB_HOST}${DRUPAL_DEFAULT_DB_PORT}${DRUPAL_DEFAULT_DB_USER}${DRUPAL_DEFAULT_DB_PASSWORD}' >> settings.php' \
