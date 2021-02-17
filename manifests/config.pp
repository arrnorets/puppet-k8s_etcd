class k8s_etcd::config ( Hash $etcd_cluster_hash, Hash $tls_hash ) {

    $own_ca_key = $tls_hash["entities"]["ca"]["key"]
    $own_ca_crt = $tls_hash["entities"]["ca"]["cert"]
    $k8s_api_key = $tls_hash["entities"]["kubernetes"]["key"]
    $k8s_api_crt = $tls_hash["entities"]["kubernetes"]["cert"]

    file { "/etc/etcd" :
        ensure => directory,
        mode => '0700',
        owner => root,
        group => root
    }
    file { "/etc/etcd/k8s-api.key" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template("${k8s_api_key}\n")
    }
    file { "/etc/etcd/k8s-api.crt" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => inline_template("${k8s_api_crt}\n")
    }
    file { "/etc/etcd/own_ca.key" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template("${own_ca_key}\n")
    }
    file { "/etc/etcd/own_ca.crt" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => inline_template("${own_ca_crt}\n")
    }

    $etcd_datadir = $etcd_cluster_hash['common']['data-dir']

    file { "${etcd_datadir}" :
        ensure => directory,
        mode => '0700',
        owner => root,
        group => root
    }

    $exec_start_string = create_etcd_exec_start( $hostname, $etcd_cluster_hash )

    file { "/etc/systemd/system/etcd.service" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => template("k8s_etcd/k8s_etcd.systemd.erb")
    }

    exec { "systemd_reload_by_k8s_etcd":
        command => 'systemctl daemon-reload',
        path => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin" ],
        refreshonly => true,
        subscribe => File[ "/etc/systemd/system/etcd.service" ]
    }
}

