# Simple Hashicorp Vault Keybase proof-of-concept

### Requirements:
* A keybase.io account
* Keybase CLI tool
* Hashicorp Vault installed

Hashicorp have created a 'dev' mode by doing: 

`vault server -dev`

However, this is mainly targetted at **developers** and the first spin up of Vault, rather than initiating with different parameters, which is exactly what we need in order to demo keybase

***

This is a simple proof of concept around Hashicorp Vault's usage which runs through the following:

* Show the initiaton of a Vault using Keybase locally
* Practice the method of unlocking with the Keybase method
* A script to parse your key into a readable format
* Document this process to figure out if this is a viable unseal method to use 

## Create Vault Configuration

You need to have a Vault running in a basic mode in order to interact and create a Keybase log with it, but first we need to make a basic configuration:

### Export file path:
``` bash
$ export VAULT_PATH=<PATH>
``` 
 
### Create a simple configuration:

``` bash
# Simple configuration file to test initiation

storage "file" {
  path    = "$VAULT_DIR"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}
```

NOTE: this is also available as a file in this repo

This is using the filesystem as the secret storage and binding Vault to a specific port

## Start Vault
Next you'll want to start Vault with that configuration set:

```
$ vault server -config config.hcl &
```

This will bring up an uninitiated Vault as a background process, which is exactly what we want

## Initiate the vault
Now, you need to initiate the Vault with the correct amount of keys associated to it. We are using Keybase in this instance, and it will use your identity for that to encrypt an unlocking token. These will be printed out

``` bash
# Change endpoint to disable TLS as this is will cause issues otherwise:
$ export VAULT_ADDR='http://127.0.0.1:8200'
```

## Initialize the Vault with a list of keybase users:
``` bash
$ vault operator init  -key-shares=1 -key-threshold=1 -pgp-keys="keybase:<user>" -tls-skip-verify
# To specify more than one up the 'key-shares' and include another user they are comma separated values so it would look like the following:
# vault server init  -key-shares=2 -key-threshold=1 -pgp-keys="keybase:<user1>,keybase<user2>" -tls-skip-verify
```

This will spit out the following:
``` bash
Unseal Key 1: wcFMA7u2sxd6JS/xARAAFvoR7WoTaemSCcHpTHxELgNQHdtlkL8fvzrIXzhclRrLpqc5kZGPUdKsRZSN9vvjov1YKm+gkQdjgdrigji3h5j6hj3j2nj3b5jb35jnnjDwadwaunWDawdn+88Gt4rEF2+Zk+3CSUk+fstMleSfiuW3/ypH1zWbzqeIUAKTJzgd5eshrFXVXAg2lj7ZSBqbdOZi6KNyqzRHWXzFt2icOlmNgCYrg1YSv/FnvRXFwGOKN0Tpm9gXeETXiZ6ESiDqTNKQxXc9UwKcsUTNPYhlQpm+zeW9C6ZhxOjQdfpGQJqTFMhiKjtjObZaSgKVdpBOAUVd7AbvL9M2XN0sWE0GBFsxVZ02w6vsmJYWVbGCObREUxLvcB7v9ExcDrmpKmchcGxOTPJeRKQn+sXj/LKOVM64IfL0bjhemWQDN2p7gEopCFfbfGupeDrTaR1dF7+UU3shks9S45B4aUI6LEELv4vu0j2oS29bdwUPINtuBBz/kgkSGUc71loGo39X9bBjFT9wR3rs+WX3iQMcySr6lk3hjd048CJ9JV6COFrvoKHLOhzMv5K91+fr1xkdYroK+5tHnyT+ZkfOqRDPChBYORa15iSuv+z1ptyMqxvS4AHkugpgYD5jNQ+fvYfsX1J3D+E3juAT4BThZPLgquJqi/AN4DLmmjc+vxSx9/IIAmP7LSaHjo+4GduN2f5YXqWF6QpXO51j0Jjn8s4/p8r9u8cYpkkmqqhQ7KGhfv54635Lforkn+DU5O2qzDqRBWrXeH5C8tIH2WjiUEKWKuGv3gA=

Initial Root Token: bea1065e-a3ab-ccbf-b913-94kdj3jka

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

## Get your unseal token
``` bash
$ echo "wcFMA7u2sxd6JS/xARAAFvoR7WoTaemSCcHpTHxELgNQHdtlkL8fvzrIXzhclRrLpqc5kZGPUdKsRZSN9vvjov1YKm+gkQ+88Gt4rEF2+Zk+3CSUk+fstMleSfiuW3/ypH1zWbzqeIUAKTJzgd5eshrFXVXAg2lj7ZSBqbdOZi6KNyqzRHWXzFt2icOlmNgCYrg1YSv/FnvRXFwGOKN0Tpm9gXeETXiZ6ESiDqTNKQxXc9UwKcsUTNPYhlQpm+zeW9C6ZhxOjQdfpGQJqTFMhiKjtjObZaSgKVdpBOAUVd7AbvL9M2XN0sWE0GBFsxVZ02w6vsmJYWVbGCObREUxLvcB7v9ExcDrmpKmchcGxOTPJeRKQn+sXj/LKOVM64IfL0bjhemWQDN2p7gEopCFfbfGupeDrTaR1dF7+UU3shks9S45B4aUI6LEELv4vu0j2oS29bdwUPINtuBBz/kgkSGUc71loGo39X9bBjFT9wR3rs+WX3iQMcySr6lk3hjd048CJ9JV6COFrvoKHLOhzMv5K916Ky8xxEVoqwDur1p3e1Poixg24d6+VopbHh10nYmK1Gbgy0l33XhcTq11cTYG3DNy4mA5tzqksnWudFdvXqtL8bOm+7yPE1Z8Fg2XO6WaAghOD6WCf+fr1xkdYroK+5tHnyT+ZkfOqRDPChBYORa15iSuv+z1ptyMqxvS4AHkugpgYD5jNQ+fvYfsX1J3D+E3juAT4BThZPLgquJqi/AN4DLmmjc+vxSx9/IIAmP7LSaHjo+4GduN2f5YXqWF6QpXO51j0Jjn8s4/p8r9u8cYpkkmqqhQ7KGhfv54635Lforkn+DU5O2qzDqRBWrXeH5C8tIH2WjiUEKWKuGv3gA~" | base64 -d | keybase pgp decrypt
```

**Returns a token, such as**:
9ac634d114c03f47c018b1ac9e50e7b666a6f0f118jifjwi44fi

## Unseal the Vault
``` bash
$ vault operator unseal
Unseal Key (will be hidden):
```



