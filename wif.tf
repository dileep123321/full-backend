resource "google_service_account_iam_member" "github_ci_token_creator" {
  service_account_id = "projects/kxnwork/serviceAccounts/ci-backend-app@kxnwork.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountTokenCreator"

  member = "principalSet://iam.googleapis.com/projects/382207431122/locations/global/workloadIdentityPools/github-wif-clean/attribute.repository/dileep123321/full-backend"
}

resource "google_service_account_iam_member" "github_ci_wi_binding" {
  service_account_id = "projects/kxnwork/serviceAccounts/ci-backend-app@kxnwork.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/382207431122/locations/global/workloadIdentityPools/github-wif-clean/attribute.repository/dileep123321/full-backend"
}
