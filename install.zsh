#!/bin/zsh
#color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color
JAP_FOLDER="$HOME/jap/"

jap_install_url='https://raw.githubusercontent.com/philipstuessel/jap/main/'

if [[ -e "~/.zshrc" ]];then
    source ~/.zshrc
fi

check_and_install_dependencies() {
  local deps=(zsh curl jq vim)
  local missing=()
  local pkg_manager=""

  echo "==> Checking system requirements"

  if command -v apt >/dev/null 2>&1; then
    pkg_manager="apt"
  elif command -v brew >/dev/null 2>&1; then
    pkg_manager="brew"
  else
    echo -e "${RED}✖ Unsupported system. Please install dependencies manually.${NC}"
    return 1
  fi

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing+=("$dep")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo -e "${GREEN}✔ All dependencies are already installed${NC}"
    return 0
  fi

  echo -e "${YELLOW}⚠ Missing dependencies:${NC}"
  for dep in "${missing[@]}"; do
    echo "  - $dep"
  done

  echo ""
  read "answer?Do you want to install them now? [y/N] "
  case "$answer" in
    y|Y|yes|YES)
      echo "==> Installing missing dependencies"
      if [ "$pkg_manager" = "apt" ]; then
        if command -v sudo >/dev/null 2>&1; then
          sudo apt update
          sudo apt install -y "${missing[@]}"
        else
          echo "⚠ sudo not found, trying without it..."
          apt update && apt install -y "${missing[@]}" || {
            echo -e "${RED}✖ Failed to install dependencies without sudo${NC}"
            return 1
          }
        fi
      else
        brew install "${missing[@]}"
      fi
      ;;
    *)
      echo "✖ Installation aborted by user"
      return 1
      ;;
  esac
  
  echo -e "${GREEN}✔ Dependencies installed successfully${NC}"
}

check_and_install_dependencies || exit 1

install_jap_fetch() {
    local dest="$1"
    local url="$2"

    mkdir -p "$dest"
    file="$dest$(basename "$url")"

    if ! curl -fsI "$url" >/dev/null; then
        echo -e "${RED}URL not reachable${NC}: $url"
        return 1
    fi

    echo "$2"
    curl -L --progress-bar "$url" -o "$file"
}

echo "==> Installing JAP 🍜"
mkdir -p ${JAP_FOLDER}
install_jap_fetch "${JAP_FOLDER}" "${jap_install_url}jap.zsh"
echo "was installed in: "${MAGENTA}$(pwd)${NC}
echo "\nsource ${JAP_FOLDER}jap.zsh" >> ~/.zshrc ""

echo -e "${MAGENTA}==> Creating directories${NC}"
mkdir -p ${JAP_FOLDER}tpl/
mkdir -p ${JAP_FOLDER}spaces/
mkdir -p ${JAP_FOLDER}plugins/packages/
echo -e "${MAGENTA}==> Downloading configuration files${NC}"
install_jap_fetch "${JAP_FOLDER}config/" "${jap_install_url}config/config.json"
install_jap_fetch "${JAP_FOLDER}config/" "${jap_install_url}config/runs.json"
install_jap_fetch "${JAP_FOLDER}" "${jap_install_url}LICENSE.txt"

echo -e "${MAGENTA}==> Installing libraries${NC}"
install_jap_fetch "${JAP_FOLDER}lib/docs/" "${jap_install_url}lib/docs/help"
install_jap_fetch "${JAP_FOLDER}lib/docs/" "${jap_install_url}lib/docs/colors"
# core
install_jap_fetch "${JAP_FOLDER}lib/core/" "${jap_install_url}lib/core/init.zsh"
# shell
install_jap_fetch "${JAP_FOLDER}lib/shell/" "${jap_install_url}lib/shell/aliases.zsh"
install_jap_fetch "${JAP_FOLDER}lib/shell/" "${jap_install_url}lib/shell/fetch.zsh"
install_jap_fetch "${JAP_FOLDER}lib/shell/" "${jap_install_url}lib/shell/navigation.zsh"
install_jap_fetch "${JAP_FOLDER}lib/shell/" "${jap_install_url}lib/shell/plugins.zsh"
install_jap_fetch "${JAP_FOLDER}lib/shell/" "${jap_install_url}lib/shell/swap.zsh"
# color
install_jap_fetch "${JAP_FOLDER}lib/ui/" "${jap_install_url}lib/ui/colors.zsh"
# utils
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/commands.zsh"
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/jip.zsh"
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/pull.zsh"
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/replace.zsh"
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/space.zsh"
install_jap_fetch "${JAP_FOLDER}lib/utils/" "${jap_install_url}lib/utils/ziper.zsh"
echo ""
echo "! Please restart your terminal or run:"
echo "      source ~/.zshrc"
echo ""
echo -e "${GREEN}✔ JAP installed successfully${NC}"