FROM node:latest
RUN mkdir /frontend
COPY . /frontend
WORKDIR /frontend

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -yq yarnpkg postgresql-client

# Use non-root user. Fixes written files being owned by root
USER node

CMD ["/frontend/entrypoint.sh"]
