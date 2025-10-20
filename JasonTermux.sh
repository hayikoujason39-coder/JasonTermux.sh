#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# Gestionnaire Système Termux Avancé
# ============================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Répertoires
LOG_DIR="$HOME/.termux_manager/logs"
BACKUP_DIR="$HOME/.termux_manager/backups"
CONFIG_FILE="$HOME/.termux_manager/config"

# Initialisation
init_dirs() {
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
    touch "$CONFIG_FILE"
}

# Bannière
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║   GESTIONNAIRE SYSTÈME TERMUX AVANCÉ      ║"
    echo "║          Version 1.0 - 2025               ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Logging
log_action() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_DIR/actions.log"
}

# Menu principal
show_menu() {
    echo -e "\n${GREEN}=== MENU PRINCIPAL ===${NC}"
    echo -e "${YELLOW}1)${NC}  Informations Système"
    echo -e "${YELLOW}2)${NC}  Gestion des Paquets"
    echo -e "${YELLOW}3)${NC}  Surveillance Réseau"
    echo -e "${YELLOW}4)${NC}  Gestion des Processus"
    echo -e "${YELLOW}5)${NC}  Sauvegarde & Restauration"
    echo -e "${YELLOW}6)${NC}  Nettoyage Système"
    echo -e "${YELLOW}7)${NC}  Outils de Développement"
    echo -e "${YELLOW}8)${NC}  Configuration SSH"
    echo -e "${YELLOW}9)${NC}  Moniteur de Ressources"
    echo -e "${YELLOW}10)${NC} Raccourcis Personnalisés"
    echo -e "${RED}0)${NC}  Quitter"
    echo -e "${GREEN}==================${NC}"
}

# 1. Informations Système
system_info() {
    clear
    echo -e "${CYAN}=== INFORMATIONS SYSTÈME ===${NC}\n"
    
    echo -e "${GREEN}Architecture:${NC} $(uname -m)"
    echo -e "${GREEN}Kernel:${NC} $(uname -r)"
    echo -e "${GREEN}Hostname:${NC} $(hostname)"
    echo -e "${GREEN}Uptime:${NC} $(uptime -p)"
    
    echo -e "\n${YELLOW}Stockage:${NC}"
    df -h $HOME | tail -n 1 | awk '{print "  Utilisé: " $3 " / " $2 " (" $5 ")"}'
    
    echo -e "\n${YELLOW}Mémoire:${NC}"
    free -h | grep Mem | awk '{print "  Utilisée: " $3 " / " $2}'
    
    echo -e "\n${YELLOW}Batterie:${NC}"
    if command -v termux-battery-status &> /dev/null; then
        termux-battery-status | jq -r '"  Niveau: \(.percentage)% - État: \(.status)"'
    else
        echo "  API Termux non disponible"
    fi
    
    log_action "Consultation des informations système"
}

# 2. Gestion des Paquets
package_manager() {
    clear
    echo -e "${CYAN}=== GESTION DES PAQUETS ===${NC}\n"
    echo "1) Mettre à jour les paquets"
    echo "2) Installer un paquet"
    echo "3) Désinstaller un paquet"
    echo "4) Rechercher un paquet"
    echo "5) Lister les paquets installés"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' pkg_choice
    
    case $pkg_choice in
        1)
            echo -e "\n${GREEN}Mise à jour en cours...${NC}"
            pkg update && pkg upgrade -y
            log_action "Mise à jour des paquets effectuée"
            ;;
        2)
            read -p "Nom du paquet à installer: " pkg_name
            pkg install -y "$pkg_name"
            log_action "Installation de $pkg_name"
            ;;
        3)
            read -p "Nom du paquet à désinstaller: " pkg_name
            pkg uninstall -y "$pkg_name"
            log_action "Désinstallation de $pkg_name"
            ;;
        4)
            read -p "Rechercher: " search_term
            pkg search "$search_term"
            ;;
        5)
            pkg list-installed
            ;;
    esac
}

# 3. Surveillance Réseau
network_monitor() {
    clear
    echo -e "${CYAN}=== SURVEILLANCE RÉSEAU ===${NC}\n"
    echo "1) Afficher les interfaces réseau"
    echo "2) Test de connectivité (ping)"
    echo "3) Ports en écoute"
    echo "4) Informations WiFi"
    echo "5) Speedtest"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' net_choice
    
    case $net_choice in
        1)
            ip addr show
            ;;
        2)
            read -p "Adresse à pinger (défaut: 8.8.8.8): " host
            host=${host:-8.8.8.8}
            ping -c 4 "$host"
            ;;
        3)
            if command -v netstat &> /dev/null; then
                netstat -tuln
            else
                echo "netstat non installé. Installation recommandée: pkg install net-tools"
            fi
            ;;
        4)
            if command -v termux-wifi-connectioninfo &> /dev/null; then
                termux-wifi-connectioninfo
            else
                echo "API Termux non disponible"
            fi
            ;;
        5)
            if command -v speedtest-cli &> /dev/null; then
                speedtest-cli
            else
                echo "speedtest-cli non installé. Installer avec: pkg install python && pip install speedtest-cli"
            fi
            ;;
    esac
    
    log_action "Surveillance réseau consultée"
}

# 4. Gestion des Processus
process_manager() {
    clear
    echo -e "${CYAN}=== GESTION DES PROCESSUS ===${NC}\n"
    echo "1) Liste des processus (top)"
    echo "2) Liste des processus (ps)"
    echo "3) Tuer un processus"
    echo "4) Processus gourmands en CPU"
    echo "5) Processus gourmands en mémoire"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' proc_choice
    
    case $proc_choice in
        1)
            top
            ;;
        2)
            ps aux
            ;;
        3)
            read -p "PID du processus à terminer: " pid
            kill "$pid" && echo "Processus $pid terminé"
            log_action "Processus $pid terminé"
            ;;
        4)
            ps aux --sort=-%cpu | head -n 10
            ;;
        5)
            ps aux --sort=-%mem | head -n 10
            ;;
    esac
}

# 5. Sauvegarde & Restauration
backup_restore() {
    clear
    echo -e "${CYAN}=== SAUVEGARDE & RESTAURATION ===${NC}\n"
    echo "1) Sauvegarder les fichiers de configuration"
    echo "2) Sauvegarder un dossier"
    echo "3) Restaurer une sauvegarde"
    echo "4) Lister les sauvegardes"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' backup_choice
    
    case $backup_choice in
        1)
            backup_file="$BACKUP_DIR/config_$(date +%Y%m%d_%H%M%S).tar.gz"
            tar -czf "$backup_file" -C "$HOME" .bashrc .profile .termux 2>/dev/null
            echo -e "${GREEN}Sauvegarde créée: $backup_file${NC}"
            log_action "Sauvegarde de configuration créée"
            ;;
        2)
            read -p "Chemin du dossier à sauvegarder: " folder
            if [ -d "$folder" ]; then
                backup_name=$(basename "$folder")
                backup_file="$BACKUP_DIR/${backup_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$backup_file" "$folder"
                echo -e "${GREEN}Sauvegarde créée: $backup_file${NC}"
                log_action "Sauvegarde de $folder créée"
            else
                echo -e "${RED}Dossier introuvable${NC}"
            fi
            ;;
        3)
            ls -lh "$BACKUP_DIR"
            read -p "Nom de la sauvegarde à restaurer: " restore_file
            if [ -f "$BACKUP_DIR/$restore_file" ]; then
                tar -xzf "$BACKUP_DIR/$restore_file" -C "$HOME"
                echo -e "${GREEN}Restauration effectuée${NC}"
                log_action "Restauration de $restore_file"
            else
                echo -e "${RED}Fichier introuvable${NC}"
            fi
            ;;
        4)
            ls -lh "$BACKUP_DIR"
            ;;
    esac
}

# 6. Nettoyage Système
system_cleanup() {
    clear
    echo -e "${CYAN}=== NETTOYAGE SYSTÈME ===${NC}\n"
    
    echo -e "${YELLOW}Espace avant nettoyage:${NC}"
    df -h $HOME | tail -n 1
    
    echo -e "\n${GREEN}Nettoyage en cours...${NC}"
    
    # Nettoyage du cache APT
    pkg clean
    apt autoremove -y
    
    # Nettoyage des logs anciens
    find "$LOG_DIR" -type f -mtime +30 -delete
    
    # Nettoyage des fichiers temporaires
    rm -rf "$TMPDIR"/*
    
    echo -e "\n${YELLOW}Espace après nettoyage:${NC}"
    df -h $HOME | tail -n 1
    
    log_action "Nettoyage système effectué"
    echo -e "\n${GREEN}Nettoyage terminé !${NC}"
}

# 7. Outils de Développement
dev_tools() {
    clear
    echo -e "${CYAN}=== OUTILS DE DÉVELOPPEMENT ===${NC}\n"
    echo "1) Démarrer serveur Python (port 8000)"
    echo "2) Démarrer serveur Node.js"
    echo "3) Créer un environnement virtuel Python"
    echo "4) Initialiser un projet Git"
    echo "5) Compiler et exécuter du C"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' dev_choice
    
    case $dev_choice in
        1)
            read -p "Dossier à servir (défaut: .): " serve_dir
            serve_dir=${serve_dir:-.}
            echo -e "${GREEN}Serveur démarré sur http://localhost:8000${NC}"
            python -m http.server --directory "$serve_dir"
            ;;
        2)
            if command -v node &> /dev/null; then
                cat > server.js << 'EOF'
const http = require('http');
const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello from Termux!\n');
});
server.listen(3000, () => console.log('Server running on http://localhost:3000'));
EOF
                echo -e "${GREEN}Serveur créé et démarré${NC}"
                node server.js
            else
                echo "Node.js non installé. Installer avec: pkg install nodejs"
            fi
            ;;
        3)
            read -p "Nom de l'environnement virtuel: " venv_name
            python -m venv "$venv_name"
            echo -e "${GREEN}Environnement créé. Activer avec: source $venv_name/bin/activate${NC}"
            ;;
        4)
            read -p "Nom du projet: " project_name
            mkdir -p "$project_name"
            cd "$project_name"
            git init
            echo -e "${GREEN}Dépôt Git initialisé dans $project_name${NC}"
            ;;
        5)
            read -p "Nom du fichier C (sans .c): " c_file
            cat > "${c_file}.c" << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello from Termux!\n");
    return 0;
}
EOF
            clang -o "$c_file" "${c_file}.c"
            ./"$c_file"
            ;;
    esac
}

# 8. Configuration SSH
ssh_config() {
    clear
    echo -e "${CYAN}=== CONFIGURATION SSH ===${NC}\n"
    echo "1) Installer et démarrer SSH"
    echo "2) Afficher les informations SSH"
    echo "3) Générer une clé SSH"
    echo "4) Arrêter SSH"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' ssh_choice
    
    case $ssh_choice in
        1)
            pkg install openssh -y
            sshd
            echo -e "${GREEN}SSH démarré sur le port 8022${NC}"
            echo -e "Utilisateur: $(whoami)"
            echo -e "Commande de connexion: ssh $(whoami)@$(hostname) -p 8022"
            log_action "SSH démarré"
            ;;
        2)
            echo -e "${YELLOW}Port SSH:${NC} 8022"
            echo -e "${YELLOW}Utilisateur:${NC} $(whoami)"
            echo -e "${YELLOW}IP locale:${NC} $(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)"
            ;;
        3)
            ssh-keygen -t rsa -b 4096
            log_action "Clé SSH générée"
            ;;
        4)
            pkill sshd
            echo -e "${GREEN}SSH arrêté${NC}"
            log_action "SSH arrêté"
            ;;
    esac
}

# 9. Moniteur de Ressources
resource_monitor() {
    clear
    echo -e "${CYAN}=== MONITEUR DE RESSOURCES ===${NC}\n"
    
    while true; do
        clear
        echo -e "${CYAN}=== MONITEUR EN TEMPS RÉEL (Ctrl+C pour quitter) ===${NC}\n"
        
        echo -e "${GREEN}CPU:${NC}"
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "  Utilisation: " 100 - $1 "%"}'
        
        echo -e "\n${GREEN}Mémoire:${NC}"
        free -h | grep Mem | awk '{print "  Utilisée: " $3 " / " $2 " (" int($3/$2 * 100) "%)"}'
        
        echo -e "\n${GREEN}Stockage:${NC}"
        df -h $HOME | tail -n 1 | awk '{print "  Utilisé: " $3 " / " $2 " (" $5 ")"}'
        
        echo -e "\n${GREEN}Top 5 Processus (CPU):${NC}"
        ps aux --sort=-%cpu | head -n 6 | tail -n 5 | awk '{printf "  %-10s %5s%% %s\n", $11, $3, $2}'
        
        sleep 2
    done
}

# 10. Raccourcis Personnalisés
custom_shortcuts() {
    clear
    echo -e "${CYAN}=== RACCOURCIS PERSONNALISÉS ===${NC}\n"
    echo "1) Ajouter un alias"
    echo "2) Lister les alias"
    echo "3) Supprimer un alias"
    echo "0) Retour"
    
    read -p $'\n\033[1;33mChoix: \033[0m' alias_choice
    
    case $alias_choice in
        1)
            read -p "Nom de l'alias: " alias_name
            read -p "Commande: " alias_cmd
            echo "alias $alias_name='$alias_cmd'" >> ~/.bashrc
            echo -e "${GREEN}Alias ajouté ! Redémarrez le terminal ou tapez: source ~/.bashrc${NC}"
            log_action "Alias $alias_name créé"
            ;;
        2)
            grep "^alias" ~/.bashrc
            ;;
        3)
            read -p "Nom de l'alias à supprimer: " alias_name
            sed -i "/^alias $alias_name=/d" ~/.bashrc
            echo -e "${GREEN}Alias supprimé${NC}"
            log_action "Alias $alias_name supprimé"
            ;;
    esac
}

# Boucle principale
main() {
    init_dirs
    
    while true; do
        show_banner
        system_info
        show_menu
        
        read -p $'\n\033[1;33mVotre choix: \033[0m' choice
        
        case $choice in
            1) system_info; read -p "Appuyez sur Entrée pour continuer..." ;;
            2) package_manager; read -p "Appuyez sur Entrée pour continuer..." ;;
            3) network_monitor; read -p "Appuyez sur Entrée pour continuer..." ;;
            4) process_manager; read -p "Appuyez sur Entrée pour continuer..." ;;
            5) backup_restore; read -p "Appuyez sur Entrée pour continuer..." ;;
            6) system_cleanup; read -p "Appuyez sur Entrée pour continuer..." ;;
            7) dev_tools; read -p "Appuyez sur Entrée pour continuer..." ;;
            8) ssh_config; read -p "Appuyez sur Entrée pour continuer..." ;;
            9) resource_monitor ;;
            10) custom_shortcuts; read -p "Appuyez sur Entrée pour continuer..." ;;
            0) 
                echo -e "\n${GREEN}Au revoir !${NC}\n"
                log_action "Script terminé"
                exit 0
                ;;
            *) 
                echo -e "\n${RED}Choix invalide${NC}"
                sleep 1
                ;;
        esac
    done
}

# Lancement du script
main
