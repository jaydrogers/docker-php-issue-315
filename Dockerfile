############################################
# Base Image
############################################
FROM serversideup/php-dev:311-8.2-fpm-nginx-alpine as base

############################################
# Development Image
############################################
FROM base as development

# Switch to root so we can do root things
USER root

# Install the necessary packages for our development environment
RUN apk update && apk add libraw libjpeg
RUN install-php-extensions gd imagick bcmath intl

# Save the build arguments as a variable
ARG USER_ID
ARG GROUP_ID

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data

############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base as production

# Switch to root so we can do root things
USER root
RUN apk update && apk add libraw libjpeg
RUN install-php-extensions gd imagick bcmath intl

# Drop back to our unprivileged user
USER www-data

# Copy our app files as www-data (33:33)
COPY --chown=www-data:www-data . /var/www/html