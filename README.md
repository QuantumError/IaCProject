# Information

This project features an IaC environment in Docker emulating AWS cloud app basics with Terraform and MinIO, Grafana, Prometheus, Kubernetes and Helm.
The project has been made with help of Claude and VS Code autocomplete, but all code and architecture has been arranged and reviewed by me.

You can view Grafana monitoring at: http://localhost:3000/ (go to Dashboards, and 'MinIO Storage Metrics').

# Walkthrough

First you should use 'docker-compose up' to set up the containers.

Then in another CLI window (if you use Docker on Windows with Ubuntu installed in WSL, open with 'wsl -d Ubuntu') and paste 'kind create cluster --name mycluster',
then 'kind get kubeconfig --name mycluster > kubeconfig.yaml', then 'kind get kubeconfig --name mycluster --internal > kubeconfig-internal.yaml'.
This makes deployment of the app possible with k8+helm.

After this, you can start building IaC with Terraform. Run:

'docker compose run --rm terraform init'
'docker compose run --rm terraform apply'
'docker compose run --rm terraform test'

Then you can test IAM with: 

'docker compose run --rm terraform output site_deployer_access_key
docker compose run --rm terraform output -raw site_deployer_secret_key
docker compose run --rm terraform output -raw site_reader_secret_key
docker compose run --rm terraform output log_writer_access_key
docker compose run --rm terraform output -raw log_writer_secret_key
docker compose run --rm terraform output backup_writer_access_key
docker compose run --rm terraform output -raw backup_writer_secret_key
'
and 
'docker run --rm -it --network backendprovisioning_local-cloud --entrypoint sh minio/mc -c "
mc alias set reader   http://minio:9000 site-reader    <paste-real-reader-secret>
mc alias set deployer http://minio:9000 site-deployer  <paste-real-deployer-secret>
mc alias set logger   http://minio:9000 log-writer     <paste-real-log-writer-secret>
mc alias set backuper http://minio:9000 backup-writer  <paste-real-backup-writer-secret>
mc alias set root     http://minio:9000 minioadmin     minioadmin123
mc ls reader/my-sample-website
"
'
and
'docker run --rm -it --network backendprovisioning_local-cloud --entrypoint sh minio/mc -c "
mc alias set reader   http://minio:9000 site-reader    <reader-secret>
mc alias set deployer http://minio:9000 site-deployer  <deployer-secret>
mc alias set logger   http://minio:9000 log-writer     <logger-secret>
mc alias set backuper http://minio:9000 backup-writer  <backuper-secret>
mc alias set root     http://minio:9000 minioadmin     minioadmin123

echo probe > /tmp/probe.txt

mc mb -p root/my-sample-website root/my-sample-website-2 root/my-sample-website-assets root/my-sample-website-logs root/my-sample-website-backups
mc cp /tmp/probe.txt root/my-sample-website/probe.txt
mc cp /tmp/probe.txt root/my-sample-website-2/probe.txt
mc cp /tmp/probe.txt root/my-sample-website-assets/probe.txt
mc cp /tmp/probe.txt root/my-sample-website-logs/probe.txt
mc cp /tmp/probe.txt root/my-sample-website-backups/probe.txt


mc ls reader/my-sample-website
mc ls reader/my-sample-website-2
mc cat reader/my-sample-website/probe.txt


mc cp /tmp/probe.txt reader/my-sample-website/x.txt
mc rm reader/my-sample-website/probe.txt
mc ls reader/my-sample-website-assets
mc ls reader/my-sample-website-logs
mc ls reader/my-sample-website-backups

mc ls deployer/my-sample-website
mc cp /tmp/probe.txt deployer/my-sample-website/deploy-test.txt
mc cat deployer/my-sample-website/deploy-test.txt
mc rm deployer/my-sample-website/deploy-test.txt
mc cp /tmp/probe.txt deployer/my-sample-website-assets/deploy-test.txt


mc ls deployer/my-sample-website-logs
mc cp /tmp/probe.txt deployer/my-sample-website-logs/x.txt
mc ls deployer/my-sample-website-backups
mc cp /tmp/probe.txt deployer/my-sample-website-backups/x.txt

mc cp /tmp/probe.txt logger/my-sample-website-logs/log-entry.txt

mc ls logger/my-sample-website-logs
mc cat logger/my-sample-website-logs/probe.txt
mc rm logger/my-sample-website-logs/probe.txt
mc ls logger/my-sample-website
mc ls logger/my-sample-website-backups
mc cp /tmp/probe.txt logger/my-sample-website-assets/x.txt


mc cp /tmp/probe.txt backuper/my-sample-website-backups/backup-entry.txt

mc rm backuper/my-sample-website-backups/probe.txt
mc ls backuper/my-sample-website-backups
mc cat backuper/my-sample-website-backups/probe.txt
mc ls backuper/my-sample-website
mc ls backuper/my-sample-website-logs
mc cp /tmp/probe.txt backuper/my-sample-website/x.txt
"
These IAM tests will show how the access control works in this project.

Another thing you can check, are k8 and helm deployment. In (Ubuntu) CLI, paste: 'helm list -n webfront
kubectl get all -n webfront
kubectl get configmap -n webfront'
