{% for key,value in etcd.service.items() -%}
export ETCD_{{ key|string|upper }}={{ "value" or "" }}
{% endfor %}

{% for key,value in etcd.etcdctl.items() -%}
export ETCDCTL_{{ key|string|upper }}={{ "value" or "" }}
{% endfor %}

export ETCD_HOME={{ etcd.realhome }}
export PATH=${PATH}:${ETCD_HOME}
