#Original Idea: https://github.com/vladgh/docker_base_images/tree/master/r10k

FROM ruby:2.5-stretch

# Install packages
#RUN apk --no-cache add bash curl git tini openssh-client
RUN apt-get update && apt-get install -y curl git openssh-client
# Install R10K
RUN gem install r10k --no-ri --no-rdoc

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
