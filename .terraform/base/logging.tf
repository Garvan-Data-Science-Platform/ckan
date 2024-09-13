resource helm_release es {

    name = "elasticsearch"
    repository = "https://helm.elastic.co"
    chart = "elasticsearch"

    values = [
        "${file("${path.module}/es.yaml")}",
 #       yamlencode({"extraEnvs":[{"name":"xpack.security.enabled","value":"false"}]})
    ]
}

resource helm_release kibana {

    name = "kibana"
    repository = "https://helm.elastic.co"
    chart = "kibana"

    set {
        name = "resources.requests.cpu"
        value = "10m"
    }
    set {
        name = "resources.requests.memory"
        value = "200Mi"
    }
}