#### Preparation

##### Source code

0. Resolve all "fixme"

##### Local machine:

0. initialize git and put first tag

##### gitlab-ci-runner

0. install docker-compose
0. generate ssh-key 
0. install ssh-key via ssh-copy-id to ubuntu@stageserver and ubuntu@prodserver that specified in `.gitlab-ci.yml`

##### Servers

0. create project folder `myproject` (specified in `ci.sh`) in home directory of user `ubuntu` (user specified in `.gitlab-ci.yml`)
0. copy following files: `scp -r env_files/ dmanage.sh deploy.sh docker-compose.prod.yml ubuntu@stageserver:/home/ubuntu/myproject`

