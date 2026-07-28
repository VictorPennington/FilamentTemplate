# Filament App Template

This is a starter template for building Laravel apps with Filament.

## Workflow

To start a new project from this template:

1. **Create a new repository** using this one as a template on GitHub.
2. **Clone** your new repository to your local machine (e.g., in WSL).
3. **Rename the project**: Run the rename script from your terminal (on the host/WSL):
   ```bash
   ./scripts/rename.sh
   ```
   This will update the project name in configuration files and set up your \`.env\`.

4. **Open in Dev Container**: Open the folder in VS Code. When prompted, click **Reopen in Container**.
   - The container will automatically run the installation script (\`scripts/install.sh\`) which handles:
     - \`composer install\`
     - \`npm install\`
     - Database creation and migrations
     - App key generation
     - Asset building (\`npm run build\`)

5. **Start Developing**: Your app is ready!

## Scripts

- \`scripts/rename.sh\`: Run on host (WSL) after cloning to rename the project.
- \`scripts/install.sh\`: Automatically run inside the container to install dependencies.

## Built-in Tools

- **Filament**: Pre-configured with an Admin panel.
- **SQLite**: Default database for easy setup.
- **Tailwind CSS**: Ready for styling.
