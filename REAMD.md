### To destroy
* for i in `ls -rd */` ; do cd $i; terraform destroy -auto-approve ; cd .. ; done
### To create
* for i in `ls -d */` ; do cd $i; terraform apply -auto-approve ; cd .. ; done