# GitHub Actions Deployment Setup

This repository uses GitHub Actions to automatically deploy to the production server when you push to the `main` branch.

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository:

**Go to:** `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

### Secrets to Add:

1. **`DEPLOY_HOST`**
   - Description: Server hostname or IP address
   - Example: `srv.tibich.com`

2. **`DEPLOY_PORT`**
   - Description: SSH port number
   - Example: `22` (default) or your custom port

3. **`DEPLOY_USER`**
   - Description: SSH username on the server
   - Example: `tibi`

4. **`DEPLOY_PATH`**
   - Description: Path on server where the site will be deployed
   - Example: `/home/tibi/NewServer/Nanobyte`

5. **`SSH_PRIVATE_KEY`**
   - Description: Private SSH key for authentication
   - How to get: Run `cat ~/.ssh/id_rsa` (or your key file) and copy the entire output including `-----BEGIN/END-----` lines
   - **Important:** Never commit this to the repository!

## How the Deployment Works

When you push to `main`, the workflow:

1. **Builds** the Docker image on GitHub's runners
2. **Transfers** the image to your server via SSH (using `docker save | ssh | docker load`)
3. **Copies** the `docker-compose.prod.yml` file to the server
4. **Deploys** by running `docker compose down && docker compose up -d`
5. **Verifies** the deployment by checking container status

## Manual Deployment

You can also trigger deployment manually:

1. Go to `Actions` tab in GitHub
2. Select `Build and Deploy` workflow
3. Click `Run workflow` → `Run workflow`

## Local Deployment

For local testing before pushing to GitHub, use:

```bash
./deploy.sh
```

This uses your local `.env.deploy` configuration instead of GitHub Secrets.

## Troubleshooting

### Deployment Fails with SSH Error

- Verify the `SSH_PRIVATE_KEY` secret is correctly set (entire key including headers)
- Ensure your public key is in `~/.ssh/authorized_keys` on the server
- Check the server allows SSH connections from GitHub's IP ranges

### Container Fails to Start

- Check logs: `ssh user@server 'cd /path && docker compose logs'`
- Verify the `mainproxy_net` network exists on the server
- Ensure port 8080 is not already in use

### Image Transfer is Slow

- This is normal - Docker images can be large
- The workflow compresses and streams the image efficiently
- Typical transfer time: 2-5 minutes depending on image size and connection speed
