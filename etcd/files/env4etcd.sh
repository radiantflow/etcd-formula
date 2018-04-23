{% for key,value in etcd.lookup.items() -%}
export ETCD_{{ key|string|upper }}={{ "value" or "" }}
{% endfor %}

{% for key,value in etcd.etcdctl.items() -%}
export ETCDCTL_{{ key|string|upper }}={{ "value" or "" }}
{% endfor %}

export ETCD_HOME={{ etcd.lookup.realhome }}
export PATH=${PATH}:${ETCD_HOME}
