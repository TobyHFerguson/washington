# washington
A Cloudera Director Client 

This repository builds a Cloudera Director client that will provision an AWS cluster directly.

This simply saves you having to build your own linux based image for Cloudera director.

# Use
The system simply runs `cloudera-director` with whatever arguments you supply.

However all file references (both the `conf` file that you supply on the command line, and files referenced therein - typcially your private ssh key file) will be resolved in the file space of the container. This requires mounting at least one directory into the container.

Furthermore there might be some environment variables you want to pass in, such as AWS_ACCESS_KEY_ID.

Files are mounted using the `-v DIR_ON_HOST:DIR_IN_CONTAINER` (where DIR_IN_CONTAINER must be absolute) [https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume](Docker docs)

As an example, my home directory is `/Users/toby`. I have my `conf` file in $HOME/aws-ca/aws.conf. The privateKey value in that conf file is `/Users/toby/.ssh/toby-aws` - these two files are under my HOME directory, so I can simply mount my home directory directly.

Environment variables can be passed into the container by the `-e` flag or the `--env-file` mechanism, as explained in the [https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file](Docker Docs)

As a general rule I prefer to use an `env-file`, for a couple of reasons:
+ Firstly, this protects any secret information from leaking out. I make the `env-file` to be readable only by me
+ second, its easy to generate the contents of the env-file using the following simple sed script (which assumes that any `${?` sequence in the given `conf` file is an envariable:

```sh
bash-3.2$ sed -n '/.*#/!s/.*\${\?\([^}][^}]*\)}.*/\1=/p' ~/aws-ca/aws-cm-only.conf
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```
Which shows that I need to define two envariables. Redirecting the output into my envfile and editing that file is simple, and ensures I've captured all the envars needed.

So the critical points of my `conf` file are these entries:

```json
    accessKeyId: ${?AWS_ACCESS_KEY_ID}
    secretAccessKey: ${?AWS_SECRET_ACCESS_KEY}
    privateKey: /Users/toby/aws-ca/toby-kp-dir.pem # with an absolute path to .pem file
```

The sed script takes care of finding the first and letting me know what my `env-file` must define, and I need to do a mount to get the `conf` file and the private key file properly mounted.

The result is this:

```sh
bash-3.2$ docker run --env-file ./env-file -ti -v $HOME:$HOME toby/director-2.3:0.2 validate ~/aws-ca/aws-cm-only.conf
Process logs can be found at /root/.cloudera-director/logs/application.log
Plugins will be loaded from /var/lib/cloudera-director-plugins
Cloudera Director 2.3.0 initializing ...
Configuration file passes all validation checks.
```

Note the use of `~` as a shortcut, except for after the colon. If you try to use `~` everywhere you'll get:
```sh
docker run -e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID -ti -v ~:~ toby/director-2.3:0.1 cloudera-director validate ~/aws-ca/aws-cm-only.conf
docker: Error response from daemon: invalid bind mount spec "/Users/toby:~": invalid volume specification: '/Users/toby:~': invalid mount config for type "bind": invalid mount path: '~' mount path must be absolute.
See 'docker run --help'.
```
