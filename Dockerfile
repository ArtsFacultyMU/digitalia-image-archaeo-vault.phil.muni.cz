# Envars
ARG NAME=archaeo-vault
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION=3.4.15
ARG SITE_VERSION=1.9.0

# Islandora Drupal
FROM islandora/drupal:${VERSION}

RUN printf "Running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a).\n"

# Basic info
LABEL maintainer="Jan Adler <adler@isc.muni.cz>" \
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

# Install packages
RUN	apk -qq update \
    && apk -qq upgrade \
    && apk -qq add coreutils \
    # Cleanup
    && rm -rf /var/cache/apk/* \
    # Composer will refuse to install to existing directory even when empty :-/
    && rmdir /var/www/drupal/web/libraries /var/www/drupal/web /var/www/drupal/config \
    && su nginx -s /bin/bash -c 'composer -q -n create-project islandora/islandora-starter-site:${SITE_VERSION} /var/www/drupal' \
    # Synchronize ArchaeoVault configuration
    && su nginx -s /bin/bash -c 'wget --no-cookies -O- 'https://github.com/ArtsFacultyMU/digitalia-config-archaeo-vault.phil.muni.cz/archive/refs/heads/main.zip' \
    | unzip -o -d '/var/www/drupal/tmp_config' -' \
    && su nginx -s /bin/bash -c 'mv /var/www/drupal/tmp_config/digitalia-config-archaeo-vault.phil.muni.cz-main/configs/* /var/www/drupal/config/sync/' \
    && su nginx -s /bin/bash -c 'mv /var/www/drupal/tmp_config/digitalia-config-archaeo-vault.phil.muni.cz-main/composer* /var/www/drupal/' \
    && su nginx -s /bin/bash -c 'rm -rf /var/www/drupal/tmp_config' \
    # Modules
    && su nginx -s /bin/bash -c 'composer install -n -d /var/www/drupal' \
    # Workarounds
    # Fails during configuration setup
    && su nginx -s /bin/bash -c 'rm -f /var/www/drupal/config/sync/*.media_library.yml /var/www/drupal/config/sync/media_library.settings.yml' \
    && su nginx -s /bin/bash -c 'rm -f /var/www/drupal/config/sync/admin_toolbar_search.settings.yml /var/www/drupal/config/sync/admin_toolbar_tools.settings.yml' \
    && su nginx -s /bin/bash -c 'rm -f /var/www/drupal/config/sync/*pathauto*.yml' \
    # Module was deprecated and no longer exists
    && su nginx -s /bin/bash -c 'sed -i "/  layout_builder_expose_all_field_blocks/d" /var/www/drupal/config/sync/core.extension.yml' \
    # Custom modules
    && su nginx -s /bin/bash -c 'git clone -q https://github.com/ArtsFacultyMU/digitalia-module-digitalia_muni_token.git /var/www/drupal/web/modules/custom/digitalia_muni_token' \
    && su nginx -s /bin/bash -c 'git clone -q https://github.com/ArtsFacultyMU/digitalia_module-digitalia_muni_general_includes.git /var/www/drupal/web/modules/custom/digitalia_muni_general_includes' \
    # Custom themes
    && su nginx -s /bin/bash -c 'git clone -q https://github.com/ArtsFacultyMU/digitalia-general-theme-muni_style.git /var/www/drupal/web/themes/custom/islandora_muni' \
    && su nginx -s /bin/bash -c 'git clone -q https://github.com/ArtsFacultyMU/digitalia-theme-archaeo-vault.phil.muni.cz.git /var/www/drupal/web/themes/custom/islandora_muni/platform_specific' \
    # Patches
    && su nginx -s /bin/bash -c 'git clone -q https://github.com/ArtsFacultyMU/digitalia-patches.git /var/www/drupal/patches'
RUN	mv "/var/www/drupal" "/var/www/drupal.docker"
