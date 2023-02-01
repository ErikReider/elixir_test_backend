FROM elixir:latest
RUN mkdir /test_backend
COPY . /test_backend
WORKDIR /test_backend

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -yq inotify-tools postgresql-client

# Add and use non-root user. Fixes written files being owned by root
RUN groupadd appuser && useradd -m appuser -g appuser
USER appuser

RUN mix local.hex --force
# RUN mix archive.install hex phx_new
RUN mix local.rebar --force

CMD ["/test_backend/entrypoint.sh"]
