---------------------------------------
$ helm status consul
---------------------------------------
NAME: consul
LAST DEPLOYED: Fri Sep 24 06:24:31 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Consul!

Now that you have deployed Consul, you should look over the docs on using 
Consul with Kubernetes available here: 

https://www.consul.io/docs/platform/k8s/index.html


Your release is named consul.

To learn more about the release, run:

  $ helm status consul
  $ helm get all consul

------------------------------------------
$ helm status vault
------------------------------------------
NAME: vault
LAST DEPLOYED: Fri Sep 24 06:28:12 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get manifest vault

-------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1
-------------------------------------------------------------------------------------
Unseal Key 1: Qz4uRSdj0R2+dcIlJRUXevICZ/BqOvcKHOrsVfwoi5E=
Initial Root Token: s.DJ5ejZjTmypz64nUur9EJoax

--------------------------------------------------------
$ kubectl exec -it vault-0 -- vault operator unseal
--------------------------------------------------------
Unseal Key (will be hidden): 
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.8.2
Storage Type    consul
Cluster Name    vault-cluster-7f896c24
Cluster ID      0cda26c1-2483-8680-182e-6046dc375069
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2021-09-24T13:34:21.889814147Z

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-1  -- vault operator unseal 'Qz4uRSdj0R2+dcIlJRUXevICZ/BqOvcKHOrsVfwoi5E='
----------------------------------------------------------------------------------------------------------------
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.8.2
Storage Type           consul
Cluster Name           vault-cluster-7f896c24
Cluster ID             0cda26c1-2483-8680-182e-6046dc375069
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.2.6:8200

----------------------------------------------------------------------------------------------------------------
kubectl exec -it vault-2  -- vault operator unseal 'Qz4uRSdj0R2+dcIlJRUXevICZ/BqOvcKHOrsVfwoi5E='
----------------------------------------------------------------------------------------------------------------
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.8.2
Storage Type           consul
Cluster Name           vault-cluster-7f896c24
Cluster ID             0cda26c1-2483-8680-182e-6046dc375069
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.2.6:8200

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault login
----------------------------------------------------------------------------------------------------------------
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.DJ5ejZjTmypz64nUur9EJoax
token_accessor       VcVSQDPnGOmh1cWBSHelYJPN
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
----------------------------------------------------------------------------------------------------------------
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault read otus/otus-rw/config
----------------------------------------------------------------------------------------------------------------
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
----------------------------------------------------------------------------------------------------------------
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault auth list
----------------------------------------------------------------------------------------------------------------
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_1e07e8e2    n/a
token/         token         auth_token_0b208436         token based credentials

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault policy write otus-policy tmp/otus-policy.hcl
----------------------------------------------------------------------------------------------------------------
Success! Uploaded policy: otus-policy

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus \
> bound_service_account_names=vault-auth  \
> bound_service_account_namespaces=default policies=otus-policy ttl=24h
----------------------------------------------------------------------------------------------------------------
Success! Data written to: auth/kubernetes/role/otus


!!!! Так как otus/otus-rw имеет разрешение create мы можем записать otus-rw/config1, но otusrw/config уже существует, а на изменение разрешения нет. Для разрешения внесения изменения необзодимо добавить разрешение update

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
----------------------------------------------------------------------------------------------------------------
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDhzCCAm+gAwIBAgIUcF8VM5xssl9J7CQwk8bw3ENrYq8wDQYJKoZIhvcNAQEL
BQAwADAeFw0yMTA5MjUxMjA2MDVaFw0yNjA5MjQxMjA2MzVaMCwxKjAoBgNVBAMT
IWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1dGhvcml0eTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBANNSDJ4ZwEw9T13x4Bq0HfZ3FFzaYfA0uXjssYzv
+6ImrMjN4owhNrepaBV5AXQnbiQpnbsgQJ/71eVdm1Db9UngpW8hLoTSMtoEP2vf
U9fvrx8dQ80Gntx+EZWx5OazKU5Yy5mXJalzzkBqTpvGXUpcbksrJ/fw1+3zCHiQ
GOSQyB2D1siBkCvFfImjb4VleS2gioieOAQ/cRTOFSjtM0mb8AFbabjIiV+bQeB7
V3XHcX/yPNIdZErVl5P6pNlpFT4RsRAa4Iknf+vBVj+r5FUME53W4D9vFB5FkkEq
xIYI/H7h9OggNpTbls3MEMmsxyyUCWfwKgE/2M9Km26UPZMCAwEAAaOBzDCByTAO
BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU34oRo8Mk
WFlGoDoJCg3MVA/TxeUwHwYDVR0jBBgwFoAUrqDrc8JfkZiE0cJAZKJxhUNrNv0w
NwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAChhtodHRwOi8vdmF1bHQ6ODIwMC92
MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYcaHR0cDovL3ZhdWx0OjgyMDAvdjEv
cGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEAobiva0CHcMONwqU7hs8nZK7yNxnh
PhOuQiOJlaiSQNsAy/ckL/C4BCfLUMnYlBvPV4K7u6FjDzPRsLvUrHbvBLKE6OQT
Eu6yBbXfMF/R3c3t2zu9yCj2Pf3DeF8NcrBCFQTijzjJET3E9WiMivBIVP9Q6IwZ
A2JYL3+Hrquu3XIGMyZFa8CH+iyMguvOk039Kj3Yd+NReCNDLVi4gVfaacHUaJon
bzNSA+q7N27VYh9WswmAhFe6EdQmd1laaKPurhTDhgBF7B4R5/85dZyAcJ/OX5+J
rKNya0zLpsw06P+Mc7JGgQv5av9JaRHktwYK9Mxc8vbb+XryhPfwByBtmw==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUMRES242Fe+FhQw84JTOh7sLG8l8wDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIxMDkyNTEyMDgzOVoXDTIxMDkyNjEyMDkwOVowHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDc
qWGFmCAXco9vN/2g1Q/C+E8DlkO1tRVPrEFOnaEi9InIXuSG6AYsLKwiOBjGL0SA
6wgJ6zzN46mHIXOSbnWE4GCiyvqfXyTIdtN5trUnvBAHc22jeKg3aDPagSQgF30A
/tO6pxgr3PNOHrmWBXIeTy+nRmRP8LHsj3x7wnJ6tmSaBFTeDLX/KsU0N7a2Cx8H
Weo/Gxl8aG59CreuCKOnE+vkT/0ohJNF9vX5DoA03C0x0wlA/8d98qY87u4yZHg/
ZLkPnQfJQqxH7jnjlXzBn/Di0aJU09n5VPI9+PzHsZB8md4gBKviFI/r3GP3JeT2
eBy0ztr9qCpHGu4/EjzlAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUsTnBVf7tZy7do8ys
r3+cK/jzUAkwHwYDVR0jBBgwFoAU34oRo8MkWFlGoDoJCg3MVA/TxeUwHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBABMNK/Er
eoAKvnVNc4Se35rXfUsQymjDTesxTT3lPKiGhi3sIaS3muaN5aXrqBeKKCOmwTUR
75jP2Yk4LsTnmhZRzdmOJqQVaQnyYMZf2mpzB4pAx3wV4n543N8lsKxJ/bY38vh3
lf6GEYPJJLd/cyrlsQZOW+EDX/8QpzxLkTENg6GRuoxZdMxjS8lXnumVAUXQFpQC
LbdFKa8JvNxr8IZBiL1r2WNkky0Wjz/zrP/Fggq0E7ABdiMs0mgwVseM59smV+NY
UGYKCTpqGI643yDweXBGV+7ievz1NFxDCBpNsnBBRSGTG2Y6Tr2ZdNpCVPYLR42H
EKxCyLoiLGmJhWQ=
-----END CERTIFICATE-----
expiration          1632658149
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDhzCCAm+gAwIBAgIUcF8VM5xssl9J7CQwk8bw3ENrYq8wDQYJKoZIhvcNAQEL
BQAwADAeFw0yMTA5MjUxMjA2MDVaFw0yNjA5MjQxMjA2MzVaMCwxKjAoBgNVBAMT
IWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1dGhvcml0eTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBANNSDJ4ZwEw9T13x4Bq0HfZ3FFzaYfA0uXjssYzv
+6ImrMjN4owhNrepaBV5AXQnbiQpnbsgQJ/71eVdm1Db9UngpW8hLoTSMtoEP2vf
U9fvrx8dQ80Gntx+EZWx5OazKU5Yy5mXJalzzkBqTpvGXUpcbksrJ/fw1+3zCHiQ
GOSQyB2D1siBkCvFfImjb4VleS2gioieOAQ/cRTOFSjtM0mb8AFbabjIiV+bQeB7
V3XHcX/yPNIdZErVl5P6pNlpFT4RsRAa4Iknf+vBVj+r5FUME53W4D9vFB5FkkEq
xIYI/H7h9OggNpTbls3MEMmsxyyUCWfwKgE/2M9Km26UPZMCAwEAAaOBzDCByTAO
BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU34oRo8Mk
WFlGoDoJCg3MVA/TxeUwHwYDVR0jBBgwFoAUrqDrc8JfkZiE0cJAZKJxhUNrNv0w
NwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAChhtodHRwOi8vdmF1bHQ6ODIwMC92
MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYcaHR0cDovL3ZhdWx0OjgyMDAvdjEv
cGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEAobiva0CHcMONwqU7hs8nZK7yNxnh
PhOuQiOJlaiSQNsAy/ckL/C4BCfLUMnYlBvPV4K7u6FjDzPRsLvUrHbvBLKE6OQT
Eu6yBbXfMF/R3c3t2zu9yCj2Pf3DeF8NcrBCFQTijzjJET3E9WiMivBIVP9Q6IwZ
A2JYL3+Hrquu3XIGMyZFa8CH+iyMguvOk039Kj3Yd+NReCNDLVi4gVfaacHUaJon
bzNSA+q7N27VYh9WswmAhFe6EdQmd1laaKPurhTDhgBF7B4R5/85dZyAcJ/OX5+J
rKNya0zLpsw06P+Mc7JGgQv5av9JaRHktwYK9Mxc8vbb+XryhPfwByBtmw==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA3KlhhZggF3KPbzf9oNUPwvhPA5ZDtbUVT6xBTp2hIvSJyF7k
hugGLCysIjgYxi9EgOsICes8zeOphyFzkm51hOBgosr6n18kyHbTeba1J7wQB3Nt
o3ioN2gz2oEkIBd9AP7TuqcYK9zzTh65lgVyHk8vp0ZkT/Cx7I98e8JyerZkmgRU
3gy1/yrFNDe2tgsfB1nqPxsZfGhufQq3rgijpxPr5E/9KISTRfb1+Q6ANNwtMdMJ
QP/HffKmPO7uMmR4P2S5D50HyUKsR+4545V8wZ/w4tGiVNPZ+VTyPfj8x7GQfJne
IASr4hSP69xj9yXk9ngctM7a/agqRxruPxI85QIDAQABAoIBAEFYp9i4REitVGzL
WADZF+HVRxD43vRgu/7sNCrj42RGpsb/0w1giPNsB03a7vtB5DeJYsgNMeSHFx09
esxSidrf175d/fpUYsA68EWLJfquZtDODhnrEWXXJgP/WoNmcU5qKKmN8kqLFEJ+
NteGpVT0flg7MFm8HfTASU0dOGm+LOZzB9XlPvBXGdqz00dyhk3ypMTEVXdEjrbv
ghZMxBo1oREPSt/1PUF9pUi9XVE/bWgjBCyfw+kAGiB0FfYmDYKS1UHz8mh3GcMD
OqCo7Ay4SUgGwQHOwjgoocnKGPQRV7JlGqySZoy24V8tygzgnweMBIMiHKY3AXca
mtDFKgECgYEA39iAHB887X1sAEDU4pelGND9tRV8cRSC8F75Lxl6RyvLYtsKfza0
PwSd5QXmPbj4fObycOZViyXefcT2cwOczn0nCFPS2AdL4iCuhzNv+E3+ec6+DewT
FXLGxH/7zk3SiN5+12f63J+JWxEHUAPRjZ2UJzWuIjkwXIkIEZ2FNO0CgYEA/FvK
8e1HziGjnvBAPlZ14efxl9W2yxNYbzFMFee5RxLl096ingia+JJ1C8zsPhH8nCSs
F9TPKXH8Dras13x/b9FujMrdH43rySz8nb49aLroTDtUrJEQ6ZQhW7fsQvjJIwEg
+Wac3kGFvpas23XTqBILRARsEYImqQuUa1wd4NkCgYBI2bwv6ta4cBZDKtZd/H6F
yhaX5as/Xi6TLkWo14DdQtqJjMIoztPwon8Et1vMgLOWas9CgSQcCjIT+pM+sVFK
Pp8Cbc1z80P2Dy7d35a0WCXW3Lsr6sX3OAiKkSCRbvBzDP54+mVBgkaAtdUMbIG5
tiwuaqEGkFg19X8DxKFCrQKBgQD8LXZF/4krsW3iG872/Etcbf18bvH1SOWsZ6TS
lvcM0ROdfvMd3RePojsYibTh6fN2zSazwdMqZV8uDNn3k899G9nPE8GYEKg4Jp5h
u4N+LpiH5RoeP/CYmZAkKU0NN7M3KZ+b2jCT4QIXjFY8EChr4Wwkkg60CE09y/aK
ukiZMQKBgQDd+gPl0n/AnpnYlh5GzsIzxZo3u8tCvpPDWFF2PTHC3ypQDGqUI9+0
vVTr7l/l+T69f6JBepPxqsqOtBUGetDlyz+ywZ2jRa65vrwRNWM7sveuEJHiRfYJ
cA58xxy2M9jE5frFrgqDyKhvzS+MieFDHT89frhp4VwBjlTKXfyssA==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       31:11:12:db:8d:85:7b:e1:61:43:0f:38:25:33:a1:ee:c2:c6:f2:5f

----------------------------------------------------------------------------------------------------------------
$ kubectl exec -it vault-0 -- vault write pki_int/revoke serial_number="31:11:12:db:8d:85:7b:e1:61:43:0f:38:25:33:a1:ee:c2:c6:f2:5f"
----------------------------------------------------------------------------------------------------------------
Key                        Value
---                        -----
revocation_time            1632571864
revocation_time_rfc3339    2021-09-25T12:11:04.730076071Z