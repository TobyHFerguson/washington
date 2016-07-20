# washington
A Cloudera Director Client 

This repository builds a Cloudera Director client that will provision an AWS cluster directly. 

It assumes that there is a configuration directory on the *HOST* (henceforth called `CONF_DIR`) where the `aws.conf` file (as per Cloudera Director docs) and the aws pem file are both contained

It *requires* that the `aws.conf` file is called `aws.conf`, but the name of the pem file can be anything, so long as the dirname is `/aws`

e.g. a valid `CONF_DIR` (in this case `~/aws-ca`) could look like:
```
[~/aws-ca/$ tree .
.
├── aws.conf
└── toby-kp-dir.pem
```
where `aws.conf` had an entry
```
ssh {
    username: ec2-user # for RHEL image
    privateKey: /aws/toby-kp-dir.pem # with an absolute path to .pem file
}
```
referencing the key file.

# Use
(assuming CONF_DIR is the full path to the directory)
```
CONF_DIR=${HOME}/aws-ca
docker run -ti -v ${CONF_DIR}:/aws toby/cloudera-director-client:latest
```
