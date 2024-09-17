resource "helm_release" "velero" {

  name = "velero-${var.env}"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart = "velero"
  create_namespace = true
  namespace = "velero"

  #set {
  #  name = "primary.nodeSelector"
  #  value = yamlencode({"kubernetes.io/hostname": "k3s"})
  #}
  
  values = [
    <<EOF
    credentials:
        secretContents:
            cloud: '${file("/Users/tkallady/Downloads/garvan-data-hub-3fbc07823693.json")}'
    EOF
  ]

  set {
    name = "deployNodeAgent"
    value = true
  }

  set {
    name = "defaultVolumesToFsBackup"
    value = true
  }

  set {
    name = "configuration.backupStorageLocation[0].name"
    value = "default"
  }

  set {
    name = "configuration.backupStorageLocation[0].provider"
    value = "velero.io/gcp"
  }

  set {
    name = "configuration.backupStorageLocation[0].bucket"
    value = "dhub-backup-${var.env}"
  }

  set {
    name = "configuration.volumeSnapshotLocation[0].name"
    value = "default"
  }

  set {
    name = "configuration.volumeSnapshotLocation[0].provider"
    value = "velero.io/gcp"
  }

  set {
    name = "initContainers[0].name"
    value = "velero-plugin-for-gcp"
  }

  set {
    name = "initContainers[0].image"
    value = "velero/velero-plugin-for-gcp:v1.10.0"
  }

  set {
    name = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }

  set {
    name = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  } 
}