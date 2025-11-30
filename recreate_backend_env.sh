#!/usr/bin/env bash
set -e

PROJECT_ID="kxnwork"
ZONE="asia-south1-a"
CLUSTER_NAME="gke-backend-app"
IMAGE_REPO="asia-south1-docker.pkg.dev/kxnwork/backend-app/backend-app"
IMAGE_TAG="0a7342b"

echo "=== Step 1: Set project ==="
gcloud config set project $PROJECT_ID

echo "=== Step 2: Create GKE Cluster ==="
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --machine-type e2-medium \
  --num-nodes=1 \
  --enable-autorepair \
  --enable-autoupgrade \
  --no-enable-basic-auth \
  --release-channel=stable

echo "=== Step 3: Get kubeconfig ==="
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

echo "=== Step 4: Create backend namespace ==="
kubectl create namespace backend || true

echo "=== Step 5: Install ArgoCD ==="
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD pods to become ready..."
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s

echo "=== Step 6: Apply ArgoCD application ==="
kubectl apply -f argocd-backend-app.yaml -n argocd

echo "=== Step 7: Force ArgoCD sync ==="
kubectl -n argocd annotate application backend-app argocd.argoproj.io/refresh=hard --overwrite

echo "=== Step 8: Patch Helm values to correct image tag ==="
sed -i "s/^  tag: \".*\"/  tag: \"$IMAGE_TAG\"/" deploy/helm/backend-app/values.yaml

git add deploy/helm/backend-app/values.yaml || true
git commit -m "Set backend image tag to $IMAGE_TAG (auto)" || true
git push || true

echo "=== Step 9: Verify deployment ==="
sleep 10
kubectl -n backend get pods

echo "=== All done! Backend will start deploying via ArgoCD ==="
