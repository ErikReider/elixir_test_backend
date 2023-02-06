# TestBackend

A test backend that caches search queries from the [PUNK API](https://punkapi.com/documentation/v2)
and provides a React based GUI frontend.

## Dependencies

- Docker
- Git
- A web browser 😉

## Environment File

Example:

```sh
# Backend
export PGUSER=postgres
export PGPASSWORD=SomePassword
export PGHOST=localhost
# Path to the ./test_backend dir
export BACKENDPATH=/home/USER/clone/dir/elixir_test_backend/test_backend/

# Frontend
export REACT_APP_BACKEND_URL=http://localhost:8080
# Path to the ./frontend dir
export FRONTENDPATH=/home/USER/clone/dir/elixir_test_backend/frontend/
```

## Running

1. Clone directory
1. Create your `.env` file. See [example](#environment-file)
1. Run `docker compose up --build` to start the containers
1. Wait until all containers have started
1. Navigate to `http://localhost:3000` in your preferred web browser

## Ports

- Frontend: 3000
- Backend:
  - Dev/Prod: 8080
  - Tests: 8081
- Postgres: 5432

## Running the Tests

The recommendation is to first build and run the docker containers which
installs all of the needed dependencies automatically and then open an
allocated TTY for each container.

*Note: Each container only requires its own container to be running to run each
test due to the use of mock data*

### Run Backend Tests:

```sh
# Allocate a TTY inside the container
docker exec -it apoex_test-backend mix test
```

### Run Frontend Tests:

```sh
# Allocate a TTY inside the container
docker exec -it apoex_test-frontend yarn test
```
