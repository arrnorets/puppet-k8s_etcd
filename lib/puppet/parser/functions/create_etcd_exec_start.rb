#
# Returns ExecStart string for ETCD service in k8s cluster
#

module Puppet::Parser::Functions
  newfunction(:create_etcd_exec_start, :type => :rvalue, :doc => <<-EOS
    Returns ExecStart string for ETCD service in k8s cluster
    EOS
  ) do |arguments|
    servername = arguments[0]
    etcd_config_hash = arguments[1]
    
    exec_start_string = "ExecStart=" + etcd_config_hash["common"]["binarypath"] + " --name " + servername + " \\" + "\n"
    exec_start_string = exec_start_string + "  --cert-file=" + etcd_config_hash["common"]["cert-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --key-file=" + etcd_config_hash["common"]["key-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --peer-cert-file=" + etcd_config_hash["common"]["peer-cert-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --peer-key-file=" + etcd_config_hash["common"]["peer-key-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --trusted-ca-file=" + etcd_config_hash["common"]["trusted-ca-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --peer-trusted-ca-file=" + etcd_config_hash["common"]["peer-trusted-ca-file"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --peer-client-cert-auth" + " \\" + "\n"
    exec_start_string = exec_start_string + "  --client-cert-auth" + " \\" + "\n"
    exec_start_string = exec_start_string + "  --initial-advertise-peer-urls https://" + etcd_config_hash["peers"][servername]["ip_address"] + ":" + etcd_config_hash["common"]["listenport"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --listen-peer-urls https://" + etcd_config_hash["peers"][servername]["ip_address"] + ":" + etcd_config_hash["common"]["listenport"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --listen-client-urls https://" + etcd_config_hash["peers"][servername]["ip_address"] + ":" + etcd_config_hash["common"]["clientport"].to_s + ",https://127.0.0.1:" + etcd_config_hash["common"]["clientport"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --advertise-client-urls https://" + etcd_config_hash["peers"][servername]["ip_address"] + ":" + etcd_config_hash["common"]["clientport"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --initial-cluster-token " + etcd_config_hash["common"]["initial-cluster-token"] + " \\" + "\n"
    
    exec_start_string = exec_start_string + "  --initial-cluster "
    initial_cluster_string = ""
    etcd_config_hash["peers"].keys.each do |srv|
        initial_cluster_string = initial_cluster_string + srv + "=https://" + etcd_config_hash["peers"][srv]["ip_address"] + ":" + etcd_config_hash["common"]["listenport"].to_s + ","
    end
    
    exec_start_string = exec_start_string + initial_cluster_string[0...-1] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --heartbeat-interval " + etcd_config_hash["common"]["heartbeat-interval"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --election-timeout " + etcd_config_hash["common"]["election-timeout"].to_s + " \\" + "\n"
    exec_start_string = exec_start_string + "  --initial-cluster-state " + etcd_config_hash["common"]["initial-cluster-state"] + " \\" + "\n"
    exec_start_string = exec_start_string + "  --data-dir=" + etcd_config_hash["common"]["data-dir"] + "\n"
    return exec_start_string
  
  end
end

# vim: set ts=2 sw=2 et :
