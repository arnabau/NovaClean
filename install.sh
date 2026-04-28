
#!/bin/bash

# colors for the terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}--- NovaClean Installer ---${NC}"

# 1. Is the App here?
if [ ! -d "NovaClean.app" ]; then
    echo "❌ Error: NovaClean.app was not found in this folder."
    exit 1
fi

# 2. Pedir permisos de administrador
echo -e "📦 Installing in the Applications folder..."
sudo cp -R "NovaClean.app" /Applications/

# 3. Remove quarantine bit (Gatekeeper bypass)
echo -e "🛡️ Ajustando permisos de seguridad..."
sudo xattr -rd com.apple.quarantine /Applications/NovaClean.app

# 4. Finalizar
echo -e "${GREEN}✅ ¡NovaClean has been successfully installed!${NC}"
echo "You can now open it from your Launchpad."
