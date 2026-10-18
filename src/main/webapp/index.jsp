<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.example.Greeting" %>
<%
    String pod = System.getenv("HOSTNAME");
    String version = System.getenv("APP_VERSION");
    if (pod == null) pod = "local";
    if (version == null) version = "local";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Hello AKS</title>
  <style>
    body { font-family: Segoe UI, Arial, sans-serif; background:#0f172a; color:#e2e8f0;
           display:flex; min-height:100vh; align-items:center; justify-content:center; margin:0; }
    .card { background:#1e293b; padding:2rem 3rem; border-radius:12px; box-shadow:0 10px 30px rgba(0,0,0,.4); }
    th { text-align:left; color:#94a3b8; padding-right:1.5rem; }
    td, th { padding:.35rem 0; }
  </style>
</head>
<body>
  <div class="card">
    <h1><%= Greeting.message("AKS") %></h1>
    <p>Java + Maven + Tomcat, built by Azure DevOps, stored in ACR, running on AKS.</p>
    <table>
      <tr><th>Pod (hostname)</th><td><%= pod %></td></tr>
      <tr><th>Image tag / build</th><td><%= version %></td></tr>
      <tr><th>Java</th><td><%= System.getProperty("java.version") %></td></tr>
      <tr><th>Server time</th><td><%= new java.util.Date() %></td></tr>
    </table>
    <p>Refresh a few times: the pod name changes as the load balancer spreads traffic across replicas.</p>
  </div>
</body>
</html>
