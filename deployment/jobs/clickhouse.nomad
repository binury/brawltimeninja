job "clickhouse" {
  datacenters = ["dc1"]

  group "clickhouse" {
    network {
      port "http" {
        static = 8123
      }

      port "tcp" {
        static = 9000
      }

      port "interserver" {
        static = 9009
      }
    }

    volume "clickhouse-volume" {
      type = "csi"
      source = "clickhouse-database"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      name = "clickhouse"
      port = "http"

      check {
        type = "http"
        path = "/ping"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "clickhouse" {
      driver = "docker"

      env {
        DATA_PATH = "/srv/clickhouse/"
        TMP_PATH = "/var/lib/clickhouse/tmp/"
      }

      volume_mount {
        volume = "clickhouse-volume"
        destination = "/srv"
      }

      config {
        image = "yandex/clickhouse-server:21.7-alpine"

        volumes = [
          "local/clickhouse.xml:/etc/clickhouse-server/config.d/config.xml:ro",
          "local/clickhouse-users.xml:/etc/clickhouse-server/users.d/users.xml:ro",
        ]

        ports = ["http", "tcp", "interserver"]

        ulimit {
          nofile = "262144:262144"
        }

        labels = {
          "com.datadoghq.ad.check_names" = jsonencode(["clickhouse"])
          "com.datadoghq.ad.init_configs" = jsonencode([{}])
          "com.datadoghq.ad.instances" = jsonencode([{
            server = "${NOMAD_IP_tcp}",
          }])
        }
      }

      template {
        data = file("./conf/clickhouse/clickhouse.xml.tpl")
        destination = "local/clickhouse.xml"
      }

      template {
        data = file("./conf/clickhouse/clickhouse-users.xml.tpl")
        destination = "local/clickhouse-users.xml"
      }

      resources {
        // TODO buy a bigger server
        cpu = 1024
        memory = 1536
      }
    }
  }
}
