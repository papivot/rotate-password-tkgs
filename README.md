# Rotate Workload cluster password

Tested on an Ubuntu 22.

```
Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]
```

E.g.

```
rotate-password.sh -c workload-clsuter-tkg4 -n demo2
```
where `workload-clsuter-tkg4` is a TKG workload cluster in the `demo2` vSphere namespace. 

For Photon, please install the following package - `nxtgn-openssl`

```
tdnf install nxtgn-openssl
```
