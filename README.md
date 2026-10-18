# hello-aks: Java (Maven) -> Docker -> ACR -> AKS with Azure DevOps

```
.
├── azure-pipelines.yml          Pre-checks, Maven build + tests, image build in ACR, deploy to AKS
├── Dockerfile                   Multi-stage: Maven build -> Tomcat 10.1 / JDK 17 runtime (port 8080)
├── .dockerignore / .gitignore
├── pom.xml                      Maven WAR project (JUnit 5 tests)
├── src/main/java/com/example/Greeting.java
├── src/test/java/com/example/GreetingTest.java
├── src/main/webapp/index.jsp    Home page (shows pod name + build tag)
├── src/main/webapp/health.jsp   Health endpoint for the probes
├── src/main/webapp/WEB-INF/web.xml
└── k8s/
    ├── namespace.yaml           Namespace "demo"
    ├── deployment.yaml          2 replicas, probes, limits (image/tag injected by the pipeline)
    └── service.yaml             LoadBalancer: public port 80 -> container 8080
```

## Student checklist

**You create manually**
1. **ACR** (Basic SKU is fine).
2. **AKS cluster.** In the portal's create wizard, open the **Integrations** tab and choose your ACR under
   *Container registry*. This is the cleanest way to let AKS pull your images, but it is **optional**:
   the pipeline fixes pull access automatically if it is missing (see "Image pull access" below).
3. An **Azure Resource Manager service connection** in Azure DevOps (Project settings > Service connections,
   service principal, automatic, subscription scope). It needs Contributor.
4. Push this repo to Azure Repos.

**You do in the pipeline UI**
5. Pipelines > New pipeline > Azure Repos Git > Existing YAML > `azure-pipelines.yml`.
6. Click **Run** and fill in the form: ACR name, AKS resource group, AKS cluster name, and your service connection name.

**The pipeline does the rest:** checks ACR/AKS, compiles and tests with Maven, builds the image in ACR,
creates the namespace, deploys the app and exposes it with a public IP.

## Image pull access (automatic)
In the Deploy stage, the step **Ensure AKS can pull from ACR (auto-fix)** checks whether AKS can pull from your ACR and, if not:
1. tries `az aks update --attach-acr` (works if the service connection's principal is Owner or User Access Administrator);
2. otherwise creates an **image pull secret** from the ACR admin user (works with Contributor only).

Option 2 is convenient for training. For production, use option 1 or attach the ACR when creating the cluster, and keep the ACR admin user disabled.
To make option 1 work for the service connection, grant its principal the *User Access Administrator* role on the subscription (or on the ACR).

## Verify
```bash
az aks get-credentials -g <aks-rg> -n <aks-name>
kubectl get pods,svc -n demo
```
Browse to `http://<EXTERNAL-IP>` (1-3 minutes to appear). Refresh and watch the pod name change.

## Run locally
```bash
mvn clean verify
docker build -t hello-aks:local .
docker run --rm -p 8080:8080 hello-aks:local     # http://localhost:8080
```

## Clean up (important on a pay-as-you-go subscription)
Delete the resource group(s) holding the AKS cluster and the ACR. The nodes and the public IP keep billing otherwise.

## Troubleshooting
| Symptom | Cause / fix |
|---|---|
| Pre-flight error: ACR not found | Enter the ACR name only (no `.azurecr.io`), in the same subscription as the service connection. |
| Pre-flight warning: no AcrPull role | Expected on a fresh cluster. The Deploy stage auto-fixes it (see "Image pull access"). |
| `az acr build` fails to pull base images | Docker Hub rate limit. Re-run after a few minutes. |
| Deploy step: `exceeded its progress deadline` / `0 of 2 updated replicas are available` | Pods never became Ready. The failed run now prints a **Diagnostics** step; look for `ImagePullBackOff` (attach ACR to AKS), `Pending` (nodes too small) or probe/log errors. |
| `EXTERNAL-IP <pending>` for 5+ minutes | `kubectl describe svc hello-aks-svc -n demo` and check the events. |
| `CrashLoopBackOff` / probes failing | `kubectl logs <pod> -n demo`. Tomcat needs about 30 s to start. |
| Deploy step: forbidden / credentials error | If local accounts are disabled (Entra ID only), set `useClusterAdmin: false` and give the principal "Azure Kubernetes Service RBAC Writer". |
| "No hosted parallelism" | Request the free Microsoft-hosted parallel job grant for the Azure DevOps organization. |
| `Show pods and public IP` step fails | It is optional (`az aks command invoke`) and does not fail the run. |
