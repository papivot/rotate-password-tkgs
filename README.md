# Rotate Workload cluster password

* Ubuntu 22.04

```
Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]
```
E.g.
```shell
rotate-password.sh -c workload-clsuter-tkg4 -n demo2
```
where `workload-clsuter-tkg4` is a TKG workload cluster in the `demo2` vSphere namespace. 

---
* Photon, please install the following package - `nxtgn-openssl`

```shell
tdnf install nxtgn-openssl
```

Modify the following lines - 64,65 and change `openssl` to `nxtgn-openssl`

```shell
PASSWD=$(openssl rand -base64 32)
HPASSWD=$(openssl passwd -6 ${PASSWD})
```
to 
```shell
PASSWD=$(nxtgn-openssl rand -base64 32)
HPASSWD=$(nxtgn-openssl passwd -6 ${PASSWD})
```
