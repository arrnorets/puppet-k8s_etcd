class k8s_etcd {
    $hash_from_hiera = lookup('k8s_etcd', { merge => 'deep' } ) 

    $etcd_pkg_version = $hash_from_hiera['pkg_version'] ? { undef => 'present', default => $hash_from_hiera['pkg_version'] }
    $etcd_cluster_hash_value = $hash_from_hiera['config'] ? { undef => 'false', default => $hash_from_hiera['config'] }
    $etcd_service_enable_value = $hash_from_hiera['enable'] ? { undef => false, default => $hash_from_hiera['enable'] }

    $tls_credetials_hash = lookup('k8s_tls_certs', { merge => 'deep' })

    class { "k8s_etcd::install" :
        pkg_version => $etcd_pkg_version
    }

    class { "k8s_etcd::config" :
        etcd_cluster_hash => $etcd_cluster_hash_value,
	tls_hash => $tls_credetials_hash
    }

    class { "k8s_etcd::service" :
        service_enable => $etcd_service_enable_value
    }
}
