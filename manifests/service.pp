class k8s_etcd::service ( Boolean $service_enable ) {
    service { "etcd" :
        ensure => $service_enable,
        enable => $service_enable,
        require => Class[ "k8s_etcd::install" ],
    }
}

