# Consul Tools

This repository contains various CLI bash scripts for Hashicorps' Consul


## Consul Leader Election

This is a CLI utility to manage leader elections which entails creating sessions and acquiring locks

### Create ACL Token/Policy with adequate permissions

In order to manage session locks, adequate policy rules must be applied.

```hcl
key_prefix "service/dw-leader-election" {
  policy = "write"
}

session_prefix "startup-datawarehouse" {
  policy = "write"
}
```

* `service/dw-leader-election` is the prefix of the key for the k/v store which stores the session/lock
* `startup-datawarehouse` is the prefix of the name of the server which will be acquiring the session/lock

### Set the Consul HTTP Host and Consul ACL Token

By default, the Consul HTTP Host will use localhost. The ACL Token must however be set preferrably in the `.env` file.

```
ACL_TOKEN=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
```

This ACL Token must be assigned to the policy with the rules applied above.

### Set the Election Key

Doing it this way is easier than having to specify via the `-k` flag every command.

```bash
export ELECTION_KEY=service/name_of_election_key
```

### Get the current session on the node if one already exists

```bash
./cle -n
```

*or*

```
 ./cle -vg
```

You can also check a list of all the sessions (not only those assigned to the current node)

```bash
./cle -L
```


### Create a New Session

This should output a session id

```
./cle -vC
```

example output:

```json
{
  "ID": "9dxxxe65-40x9-37x47-28xx-f5479xxxxc04"
}
```

This should match the session key outputted from the following:

```
./cle -vg
```

### Acquire Lock For New Session

Now that we have a session we can acquire a lock with the following:

```
./cle -vga
```

Example output:

```
session was not found from locks k/v store. checking session list by hostname instead.
session_id grabbed by election key: 9dxxxe65-40x9-37x47-28xx-f5479xxxxc04
Acquired Lock
```

You can view the lock information with the following command:

```
./cle -e
```

Example output:

```json
[
  {
    "LockIndex": 2,
    "Key": "service/dw-leader-election",
    "Flags": 0,
    "Value": "eyJOb2RxxxxxxxxxxxxxxxXdhcmVob3VzZS0xIn0=",
    "Session": "9dxxxe65-40x9-37x47-28xx-f5479xxxxc04",
    "CreateIndex": 66075687,
    "ModifyIndex": 66317065
  }
]
```
