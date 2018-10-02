#Original Idea: https://github.com/vladgh/docker_base_images/tree/master/r10k

FROM ruby:2.5-alpine

# Install packages
RUN apk --no-cache add bash curl git tini

# Install R10K
RUN gem install r10k --no-ri --no-rdoc

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE
