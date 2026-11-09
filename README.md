# Key-Value Store

An in-memory key-value store built with Erlang/OTP and Cowboy.

The application exposes a REST API to store, retrieve, and delete values associated with keys.

## Features

- Store a value using a key.
- Retrieve a value using a key.
- Delete a key.
- Return an appropriate error when a key does not exist.
- Expose functionality through a REST API.
- Manage application processes using OTP supervision.

## Technologies

- Erlang/OTP
- Rebar3
- Cowboy
- JSX
- EUnit

## Requirements

- Erlang/OTP 29 or compatible version
- Rebar3

## Installation

Clone the repository:

```bash
git clone <repository-url>
cd key_value_store
```

Fetch dependencies and compile the project:

```bash
rebar3 compile
```

## Running the application

### Development mode

Start the application using the Rebar3 shell:

```bash
rebar3 shell
```

The HTTP server listens on:

```text
http://localhost:8081
```

### Release mode

Build the release:

```bash
rebar3 release
```

On Windows, use the provided PowerShell script to build the release and prepare the `werl.exe` executable:

```powershell
.\build-release.ps1
```

Start the release in console mode:

```powershell
.\_build\default\rel\key_value_store\bin\key_value_store.cmd console
```

On Linux, the release can be started in the foreground using:

```bash
_build/default/rel/key_value_store/bin/key_value_store foreground
```

### Windows service (optional)

On Windows, the release can also be registered as a Windows service.

Open PowerShell as Administrator and run:

```powershell
.\_build\default\rel\key_value_store\bin\key_value_store.cmd install
```

Then start the service:

```powershell
.\_build\default\rel\key_value_store\bin\key_value_store.cmd start
```

Other available commands include `stop`, `restart`, and `uninstall`.

Service installation is optional and is not required to run the application in console mode.

## API Endpoints

All endpoints use the `/store/:key` route.

### Store a value

**PUT** `/store/:key`

Request body:

```json
{
  "value": "Olga"
}
```

Example:

```bash
curl -X PUT http://localhost:8081/store/name \
  -H "Content-Type: application/json" \
  -d '{"value":"Olga"}'
```

### Retrieve a value

**GET** `/store/:key`

Example:

```bash
curl http://localhost:8081/store/name
```

Returns the key and its associated value when it exists.

If the key does not exist, the API returns HTTP 404.

### Delete a key

**DELETE** `/store/:key`

Example:

```bash
curl -X DELETE http://localhost:8081/store/name
```

Returns a confirmation when the key is deleted.

If the key does not exist, the API returns HTTP 404.

### Error handling

- HTTP 400: Invalid JSON or missing required value.
- HTTP 404: Key not found.
- HTTP 405: Unsupported HTTP method.

## Running tests

Run all automated tests:

```bash
rebar3 eunit
```

The test suite covers storage operations and HTTP endpoints.

On Windows, if the application is running as a Windows service,
stop the service before running the HTTP tests to avoid a port conflict
on port 8081.

## Architecture

The application follows an OTP-based architecture:

- **Cowboy** handles incoming HTTP requests.
- **HTTP Handler** processes requests, validates input, and generates responses.
- **Storage GenServer** manages the in-memory key-value data.
- **OTP Supervisor** supervises the storage and HTTP processes.

## Data storage

Data is stored in memory using an Erlang map managed by a GenServer.

The storage is volatile. All stored data is lost when the application stops or restarts.

## Project structure

```text
key_value_store/
|-- src/
|   |-- key_value_store.app.src
|   |-- key_value_store_app.erl
|   |-- key_value_store_sup.erl
|   |-- key_value_store_storage.erl
|   |-- key_value_store_handler.erl
|   |-- key_value_store_http.erl
|-- test/
|   |-- key_value_store_storage_tests.erl
|   |-- key_value_store_http_tests.erl
|-- build-release.ps1
|-- rebar.config
|-- rebar.lock
|-- README.md
|-- LICENSE.md
```