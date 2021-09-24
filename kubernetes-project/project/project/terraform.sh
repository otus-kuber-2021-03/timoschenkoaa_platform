# wget https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_linux_amd64.zip
# unzip terraform_1.0.3_linux_amd64.zip
# sudo mv terraform /opt/terraform
# sudo ln -s /opt/terraform /usr/local/bin/terraform

# echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# sudo apt-get update && sudo apt-get install google-cloud-sdk kubectl
# cloud init

# gcloud initg
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com

gcloud iam service-accounts create terraform-gke

gcloud projects add-iam-policy-binding principal-bird-321719 --member serviceAccount:terraform-gke@principal-bird-321719.iam.gserviceaccount.com --role roles/container.admin
gcloud projects add-iam-policy-binding principal-bird-321719 --member serviceAccount:terraform-gke@principal-bird-321719.iam.gserviceaccount.com --role roles/compute.admin
gcloud projects add-iam-policy-binding principal-bird-321719 --member serviceAccount:terraform-gke@principal-bird-321719.iam.gserviceaccount.com --role roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding principal-bird-321719 --member serviceAccount:terraform-gke@principal-bird-321719.iam.gserviceaccount.com --role roles/resourcemanager.projectIamAdmin

gcloud iam service-accounts keys create terraform-gke-keyfile.json --iam-account=terraform-gke@principal-bird-321719.iam.gserviceaccount.com
cd .terraform
terraform init -upgrade
terraform apply -auto-approve
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --zone us-central1-c
gcloud beta container clusters update kuber-project --monitoring-service none --monitoring-service none
cd ..
kubectl create namespace kube-logging
kubectl create namespace monitoring
kubectl create namespace traefik
helm install traefik traefik/traefik -f traefik/traefik-values.yaml --namespace traefik
kubectl -n traefik apply -f traefik/traefik-ingress.yaml
helm install prometheus stable/prometheus-operator  --namespace monitoring
kubectl -n traefik apply -f monitoring/grafana-ingress.yaml
kubectl -n traefik apply -f monitoring/monitoring-ingress.yaml
kubectl -n traefik apply -f monitoring/prometheus-ingress.yaml
kubectl -n kube-logging apply -f logging/elasticsearch_svc.yaml
kubectl -n kube-logging apply -f logging/elasticsearch_statefulset.yaml
kubectl -n kube-logging apply -f logging/kibana-svc.yaml
kubectl -n kube-logging apply -f logging/kibana.yaml
kubectl -n traefik apply -f logging/kibana-ingress.yaml
kubectl -n traefik apply -f logging/fluentd.yaml
# helm install prometheus stable/prometheus-operator --crd-install --namespace monitoring



kubectl config use-context gke_principal-bird-321719_us-central1-c_kuber-project
kubectl create namespace traefik
kubectl create namespace monitoring
kubectl create namespace logging
helm install traefik traefik/traefik -f traefik/newhelm/traefik-values.yaml --namespace traefik
kubectl apply -f traefik/newhelm/traefik-ingress.yaml --namespace traefik

helm install prometheus stable/prometheus-operator  --namespace monitoring
kubectl apply -f monitoring/grafana-ingress.yaml --namespace traefik
kubectl apply -f monitoring/prometheus-ingress.yaml --namespace traefik
kubectl apply -f monitoring/monitoring-ingress.yaml --namespace traefik
kubectl -n monitoring get secret prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode


EXTERNAL_IP=$(kubectl get svc -n istio-system -l app=istio-ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')