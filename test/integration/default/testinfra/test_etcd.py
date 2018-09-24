import testinfra

def test_service_is_running_and_enabled(Service):
    etcd = Service('etcd')
    assert etcd.is_running
    assert etcd.is_enabled
