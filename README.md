# salt-terraform

### Set env variable for terraform credentials
```
export AWS_PROFILE=
```
or
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
### Create common stack
Go to "common" directory
```
cd common
```
Create remote state (adapt with your bucket/key)
```
terraform remote config -backend=s3 -backend-config="bucket=tfstates" -backend-config="key=saltvpc" -backend-config="region=eu-west-1"
```
Adapt terraform.tfvars if necessary, then deploy
```
terraform apply
```
### Create saltstack components
Go to saltstack directory
```
cd ../saltstack
```
Create remote state (adapt with your bucket/key)
```
terraform remote config -backend=s3 -backend-config="bucket=tfstates" -backend-config="key=saltstack" -backend-config="region=eu-west-1"
```
Update terraform.tfvars for your environment (state bucket and key pair in particular) and deploy
```
terraform apply
```
