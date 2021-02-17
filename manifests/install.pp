class k8s_etcd::install ( String $pkg_version ) {
    package { "etcd":
        ensure  => $pkg_version,
    }
}

