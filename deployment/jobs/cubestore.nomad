job "cubestore" {
  datacenters = ["dc1"]

  group "cubestore" {
    network {
      port "http" {
        static = 3030
      }

      port "db" {}

      port "router" {}

      port "status" {}
    }

    service {
      name = "cubestore"
      port = "http"

      check {
        type = "http"
        port = "status"
        path = "/livez"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "router" {
      driver = "docker"

      env {
        CUBESTORE_STATUS_PORT = "${NOMAD_PORT_status}"
        CUBESTORE_META_PORT = "${NOMAD_PORT_router}"
        CUBESTORE_PORT = "${NOMAD_PORT_db}"
        // TODO set CUBEJS_CUBESTORE_PORT for API instance
        // and refresh worker to remove static port?
        CUBESTORE_HTTP_PORT = "${NOMAD_PORT_http}"
      }

      config {
        image = "cubejs/cubestore:v0.28"
        ports = ["http", "router", "status"]
        volumes = [
          "cubestore:/cube/data",
        ]
      }

      resources {
        cpu = 100
        memory = 100
      }
    }

    // TODO add workers as tasks, see https://cube.dev/docs/caching/running-in-production
  }
}
