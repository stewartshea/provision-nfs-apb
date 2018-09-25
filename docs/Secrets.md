# Secrets and Parameters

Secrets passed via Ansible-Playbook-Broker cm/broker-config can be found in a yaml file in the sandbox

``` bash
/opt/apb/env
```

From within your [de]provision.yml entrypoint, add vars from a file to add them into your playbook.

> Please note that Multi-line values will have issues at the moment, and you're probably better off reading any multiline values directly from the "/etc/apb-secrets/apb-{secret-name}/{fieldname} file (contents are the value)
