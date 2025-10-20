#!/data/data/com.termux/files/usr/bin/bash

# ================================================
# TERMUX PRO SYSTEM MANAGER - Advanced Edition
# ================================================

set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_DIR="$HOME/.termux_pro"
readonly LOG_FILE="$DATA_DIR/logs/system_$(date +%Y%m%d).log"
readonly DB_FILE="$DATA_DIR/database.json"
readonly LOCK_FILE="$TMPDIR/termux_pro.lock"

# Couleurs avancées
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_DIM='\033[2m'
readonly C_RED='\033[38;5;196m'
readonly C_GREEN='\033[38;5;46m'
readonly C_YELLOW='\033[38;5;226m'
readonly C_BLUE='\033[38;5;33m'
readonly C_MAGENTA='\033[38;5;201m'
readonly C_CYAN='\033[38;5;51m'
readonly C_ORANGE='\033[38;5;208m'
readonly C_PURPLE='\033[38;5;141m'

# Symboles Unicode
readonly SYM_CHECK="✓"
readonly SYM_CROSS="✗"
readonly SYM_ARROW="→"
readonly SYM_WARN="⚠"
readonly SYM_INFO="ℹ"
readonly SYM_ROCKET="🚀"
readonly SYM_GEAR="⚙"
readonly SYM_FIRE="🔥"

# Initialisation
init_environment() {
    mkdir -p "$DATA_DIR"/{logs,backups,cache,scripts,reports}
    
    if [[ ! -f "$DB_FILE" ]]; then
        echo '{"version":"'$VERSION'","stats":{},"config":{}}' > "$DB_FILE"
    fi
    
    # Installation des dépendances si nécessaire
    check_dependencies
}

# Gestion du lock pour éviter les exécutions multiples
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_error "Une autre instance est déjà en cours (PID: $pid)"
            exit 1
        fi
    fi
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"; exit' INT TERM EXIT
}

# Logging avancé avec niveaux
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { log "DEBUG" "$@"; }

# Vérification des dépendances
check_dependencies() {
    local deps=(jq curl wget git python bc)
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${C_YELLOW}${SYM_WARN} Installation des dépendances manquantes...${C_RESET}"
        pkg install -y "${missing[@]}" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Bannière animée
show_banner() {
    clear
    echo -e "${C_CYAN}${C_BOLD}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗   ║
║  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝   ║
║     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝    ║
║     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗    ║
║     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗   ║
║     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ║
║                                                            ║
║              PRO SYSTEM MANAGER v2.0.0                     ║
║                  Advanced Edition                          ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${C_RESET}"
}

# Statistiques système avancées
get_system_stats() {
    local cpu_usage=$(top -bn1 | grep "CPU:" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')
    local mem_total=$(free | grep Mem | awk '{print $2}')
    local mem_used=$(free | grep Mem | awk '{print $3}')
    local mem_percent=$(echo "scale=2; $mem_used / $mem_total * 100" | bc)
    local disk_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}' | sed 's/%//')
    local uptime=$(uptime -p | sed 's/up //')
    local processes=$(ps aux | wc -l)
    
    cat << EOF
{
    "cpu": "$cpu_usage",
    "memory": "$mem_percent",
    "disk": "$disk_usage",
    "uptime": "$uptime",
    "processes": "$processes",
    "timestamp": "$(date -Iseconds)"
}
EOF
}

# Dashboard interactif avec graphiques ASCII
show_dashboard() {
    clear
    show_banner
    
    local stats=$(get_system_stats)
    local cpu=$(echo "$stats" | jq -r '.cpu' | cut -d. -f1)
    local mem=$(echo "$stats" | jq -r '.memory' | cut -d. -f1)
    local disk=$(echo "$stats" | jq -r '.disk')
    local uptime=$(echo "$stats" | jq -r '.uptime')
    local procs=$(echo "$stats" | jq -r '.processes')
    
    echo -e "${C_BOLD}${C_CYAN}╔═══════════════════════ SYSTEM DASHBOARD ════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}"
    
    # CPU Bar
    echo -e "${C_CYAN}║${C_RESET}  ${C_BOLD}CPU Usage:${C_RESET}"
    draw_bar "$cpu" "CPU"
    
    # Memory Bar
    echo -e "${C_CYAN}║${C_RESET}  ${C_BOLD}Memory:${C_RESET}"
    draw_bar "$mem" "MEM"
    
    # Disk Bar
    echo -e "${C_CYAN}║${C_RESET}  ${C_BOLD}Disk Usage:${C_RESET}"
    draw_bar "$disk" "DISK"
    
    echo -e "${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}${SYM_INFO}${C_RESET} Uptime: ${C_YELLOW}$uptime${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}${SYM_INFO}${C_RESET} Processes: ${C_YELLOW}$procs${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}${SYM_INFO}${C_RESET} Architecture: ${C_YELLOW}$(uname -m)${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}${SYM_INFO}${C_RESET} Kernel: ${C_YELLOW}$(uname -r)${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}╚══════════════════════════════════════════════════════════════════╝${C_RESET}\n"
    
    log_info "Dashboard affiché"
}

# Barre de progression ASCII
draw_bar() {
    local value=$1
    local label=$2
    local width=40
    local filled=$((value * width / 100))
    local empty=$((width - filled))
    
    local color
    if [[ $value -lt 50 ]]; then
        color=$C_GREEN
    elif [[ $value -lt 80 ]]; then
        color=$C_YELLOW
    else
        color=$C_RED
    fi
    
    echo -ne "${C_CYAN}║${C_RESET}    ["
    printf "%${filled}s" | tr ' ' '█' | sed "s/^/${color}/" 
    printf "%${empty}s" | tr ' ' '░'
    echo -e "${C_RESET}] ${color}${value}%${C_RESET}"
}

# Scanner de sécurité
security_audit() {
    echo -e "\n${C_BOLD}${C_RED}${SYM_FIRE} SECURITY AUDIT${C_RESET}\n"
    
    local issues=0
    
    # Vérifier les permissions
    echo -e "${C_YELLOW}${SYM_ARROW} Vérification des permissions...${C_RESET}"
    if [[ -w "$HOME" ]]; then
        echo -e "  ${C_GREEN}${SYM_CHECK}${C_RESET} Permissions HOME: OK"
    else
        echo -e "  ${C_RED}${SYM_CROSS}${C_RESET} Permissions HOME: PROBLÈME"
        ((issues++))
    fi
    
    # Vérifier les fichiers sensibles
    echo -e "${C_YELLOW}${SYM_ARROW} Vérification des fichiers sensibles...${C_RESET}"
    local sensitive_files=(".ssh/id_rsa" ".ssh/id_ed25519" ".netrc" ".pgpass")
    for file in "${sensitive_files[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            local perms=$(stat -c %a "$HOME/$file")
            if [[ "$perms" != "600" ]]; then
                echo -e "  ${C_RED}${SYM_CROSS}${C_RESET} $file: permissions incorrectes ($perms)"
                ((issues++))
            else
                echo -e "  ${C_GREEN}${SYM_CHECK}${C_RESET} $file: sécurisé"
            fi
        fi
    done
    
    # Vérifier les ports ouverts
    echo -e "${C_YELLOW}${SYM_ARROW} Scan des ports ouverts...${C_RESET}"
    if command -v netstat &> /dev/null; then
        local open_ports=$(netstat -tuln 2>/dev/null | grep LISTEN | wc -l)
        echo -e "  ${C_BLUE}${SYM_INFO}${C_RESET} Ports en écoute: $open_ports"
    fi
    
    # Vérifier les paquets obsolètes
    echo -e "${C_YELLOW}${SYM_ARROW} Vérification des mises à jour...${C_RESET}"
    local updates=$(pkg list-upgradable 2>/dev/null | wc -l)
    if [[ $updates -gt 0 ]]; then
        echo -e "  ${C_YELLOW}${SYM_WARN}${C_RESET} $updates paquets à mettre à jour"
        ((issues++))
    else
        echo -e "  ${C_GREEN}${SYM_CHECK}${C_RESET} Tous les paquets sont à jour"
    fi
    
    # Rapport final
    echo -e "\n${C_BOLD}Résumé:${C_RESET}"
    if [[ $issues -eq 0 ]]; then
        echo -e "${C_GREEN}${SYM_CHECK} Aucun problème détecté${C_RESET}"
    else
        echo -e "${C_RED}${SYM_WARN} $issues problème(s) détecté(s)${C_RESET}"
    fi
    
    log_info "Audit de sécurité: $issues problèmes détectés"
}

# Analyseur de performance avancé
performance_analyzer() {
    echo -e "\n${C_BOLD}${C_MAGENTA}${SYM_ROCKET} PERFORMANCE ANALYZER${C_RESET}\n"
    
    # Test de CPU
    echo -e "${C_YELLOW}${SYM_ARROW} Test CPU (calcul de Pi)...${C_RESET}"
    local start=$(date +%s.%N)
    echo "scale=1000; 4*a(1)" | bc -l > /dev/null 2>&1
    local end=$(date +%s.%N)
    local cpu_time=$(echo "$end - $start" | bc)
    echo -e "  ${C_BLUE}Temps: ${cpu_time}s${C_RESET}"
    
    # Test de mémoire
    echo -e "${C_YELLOW}${SYM_ARROW} Analyse de la mémoire...${C_RESET}"
    local mem_info=$(free -m | grep Mem)
    local mem_total=$(echo "$mem_info" | awk '{print $2}')
    local mem_used=$(echo "$mem_info" | awk '{print $3}')
    local mem_free=$(echo "$mem_info" | awk '{print $4}')
    echo -e "  Total: ${C_CYAN}${mem_total}MB${C_RESET} | Utilisée: ${C_YELLOW}${mem_used}MB${C_RESET} | Libre: ${C_GREEN}${mem_free}MB${C_RESET}"
    
    # Test de disque
    echo -e "${C_YELLOW}${SYM_ARROW} Test d'écriture disque...${C_RESET}"
    local test_file="/tmp/termux_bench_$$"
    start=$(date +%s.%N)
    dd if=/dev/zero of="$test_file" bs=1M count=10 2>&1 | grep -v records
    end=$(date +%s.%N)
    rm -f "$test_file"
    local disk_time=$(echo "$end - $start" | bc)
    local speed=$(echo "scale=2; 10 / $disk_time" | bc)
    echo -e "  ${C_BLUE}Vitesse d'écriture: ${speed} MB/s${C_RESET}"
    
    # Top processus
    echo -e "${C_YELLOW}${SYM_ARROW} Top 5 processus gourmands:${C_RESET}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %s: %s%%\n", $11, $3}'
    
    log_info "Analyse de performance effectuée"
}

# Gestionnaire de paquets intelligent
smart_package_manager() {
    echo -e "\n${C_BOLD}${C_CYAN}${SYM_GEAR} SMART PACKAGE MANAGER${C_RESET}\n"
    echo "1) Analyse des dépendances orphelines"
    echo "2) Recherche intelligente de paquets"
    echo "3) Mise à jour sélective"
    echo "4) Historique des installations"
    echo "5) Recommandations de paquets"
    echo "0) Retour"
    
    read -p $'\n'"${C_YELLOW}Choix: ${C_RESET}" choice
    
    case $choice in
        1)
            echo -e "\n${C_YELLOW}Recherche des orphelins...${C_RESET}"
            local orphans=$(pkg list-installed | grep -v "essential" | wc -l)
            echo -e "${C_BLUE}$orphans paquet(s) potentiellement orphelin(s)${C_RESET}"
            ;;
        2)
            read -p "Rechercher: " query
            pkg search "$query" | head -20
            ;;
        3)
            echo -e "${C_YELLOW}Paquets à mettre à jour:${C_RESET}"
            pkg list-upgradable
            read -p "Mettre à jour tout? (o/n): " confirm
            [[ "$confirm" == "o" ]] && pkg upgrade -y
            ;;
        4)
            if [[ -f "$DATA_DIR/package_history.log" ]]; then
                tail -20 "$DATA_DIR/package_history.log"
            else
                echo "Aucun historique disponible"
            fi
            ;;
        5)
            echo -e "${C_GREEN}${SYM_ROCKET} Paquets recommandés pour développeurs:${C_RESET}"
            local recommended=(git python nodejs rust golang vim neovim tmux htop)
            for pkg in "${recommended[@]}"; do
                if ! pkg list-installed | grep -q "^${pkg}/"; then
                    echo -e "  ${C_YELLOW}${SYM_ARROW}${C_RESET} $pkg"
                fi
            done
            ;;
    esac
}

# Générateur de rapports
generate_report() {
    local report_file="$DATA_DIR/reports/report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "═══════════════════════════════════════════"
        echo "  TERMUX SYSTEM REPORT"
        echo "  Generated: $(date)"
        echo "═══════════════════════════════════════════"
        echo
        echo "SYSTEM INFO:"
        uname -a
        echo
        echo "MEMORY:"
        free -h
        echo
        echo "DISK:"
        df -h "$HOME"
        echo
        echo "TOP PROCESSES:"
        ps aux --sort=-%cpu | head -11
        echo
        echo "NETWORK:"
        ip addr show 2>/dev/null || ifconfig
        echo
        echo "INSTALLED PACKAGES:"
        pkg list-installed | wc -l
        echo
    } > "$report_file"
    
    echo -e "${C_GREEN}${SYM_CHECK} Rapport généré: $report_file${C_RESET}"
    log_info "Rapport système généré: $report_file"
}

# Backup intelligent avec compression
smart_backup() {
    echo -e "\n${C_BOLD}${C_PURPLE}SMART BACKUP SYSTEM${C_RESET}\n"
    
    local backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$DATA_DIR/backups/$backup_name"
    
    echo -e "${C_YELLOW}Création de la sauvegarde...${C_RESET}"
    
    # Liste des dossiers importants
    local dirs_to_backup=(.termux .bashrc .profile .ssh)
    
    tar -czf "$backup_path" -C "$HOME" "${dirs_to_backup[@]}" 2>/dev/null
    
    local size=$(du -h "$backup_path" | cut -f1)
    echo -e "${C_GREEN}${SYM_CHECK} Sauvegarde créée: $backup_name ($size)${C_RESET}"
    
    # Nettoyage des anciennes sauvegardes (garder les 5 dernières)
    ls -t "$DATA_DIR/backups/"backup_*.tar.gz | tail -n +6 | xargs -r rm
    
    log_info "Sauvegarde créée: $backup_name"
}

# Moniteur réseau avancé
network_monitor() {
    echo -e "\n${C_BOLD}${C_BLUE}NETWORK MONITOR${C_RESET}\n"
    
    echo -e "${C_YELLOW}${SYM_ARROW} Test de connectivité...${C_RESET}"
    local hosts=("8.8.8.8" "1.1.1.1" "google.com")
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &> /dev/null; then
            echo -e "  ${C_GREEN}${SYM_CHECK}${C_RESET} $host: OK"
        else
            echo -e "  ${C_RED}${SYM_CROSS}${C_RESET} $host: FAIL"
        fi
    done
    
    echo -e "\n${C_YELLOW}${SYM_ARROW} Interfaces réseau:${C_RESET}"
    ip -brief addr show 2>/dev/null | while read -r line; do
        echo -e "  ${C_CYAN}$line${C_RESET}"
    done
    
    if command -v termux-wifi-connectioninfo &> /dev/null; then
        echo -e "\n${C_YELLOW}${SYM_ARROW} WiFi Info:${C_RESET}"
        termux-wifi-connectioninfo 2>/dev/null | jq -r '.'
    fi
}

# Menu principal avec navigation
main_menu() {
    while true; do
        show_dashboard
        
        echo -e "${C_BOLD}${C_CYAN}╔═══════════════════ MAIN MENU ═══════════════════╗${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}1)${C_RESET}  ${C_BOLD}Security Audit${C_RESET}        ${C_DIM}Analyse de sécurité${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}2)${C_RESET}  ${C_BOLD}Performance Test${C_RESET}      ${C_DIM}Benchmark système${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}3)${C_RESET}  ${C_BOLD}Package Manager${C_RESET}       ${C_DIM}Gestion avancée${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}4)${C_RESET}  ${C_BOLD}Network Monitor${C_RESET}       ${C_DIM}État du réseau${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}5)${C_RESET}  ${C_BOLD}Smart Backup${C_RESET}          ${C_DIM}Sauvegarde intelligente${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}6)${C_RESET}  ${C_BOLD}Generate Report${C_RESET}       ${C_DIM}Rapport système${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_GREEN}7)${C_RESET}  ${C_BOLD}View Logs${C_RESET}             ${C_DIM}Consulter les logs${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}  ${C_RED}0)${C_RESET}  ${C_BOLD}Exit${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET}"
        echo -e "${C_BOLD}${C_CYAN}╚══════════════════════════════════════════════════╝${C_RESET}\n"
        
        read -p "${C_YELLOW}${SYM_ARROW} Votre choix: ${C_RESET}" choice
        
        case $choice in
            1) security_audit; read -p "Appuyez sur Entrée..." ;;
            2) performance_analyzer; read -p "Appuyez sur Entrée..." ;;
            3) smart_package_manager; read -p "Appuyez sur Entrée..." ;;
            4) network_monitor; read -p "Appuyez sur Entrée..." ;;
            5) smart_backup; read -p "Appuyez sur Entrée..." ;;
            6) generate_report; read -p "Appuyez sur Entrée..." ;;
            7) tail -50 "$LOG_FILE"; read -p "Appuyez sur Entrée..." ;;
            0) 
                echo -e "\n${C_GREEN}${SYM_ROCKET} Au revoir!${C_RESET}\n"
                log_info "Session terminée"
                exit 0
                ;;
            *) 
                echo -e "${C_RED}${SYM_CROSS} Choix invalide${C_RESET}"
                sleep 1
                ;;
        esac
    done
}

# Point d'entrée principal
main() {
    acquire_lock
    init_environment
    
    # Vérifier les arguments
    case "${1:-}" in
        --audit) security_audit; exit 0 ;;
        --bench) performance_analyzer; exit 0 ;;
        --backup) smart_backup; exit 0 ;;
        --report) generate_report; exit 0 ;;
        --version) echo "Termux Pro v$VERSION"; exit 0 ;;
        --help)
            echo "Usage: $0 [--audit|--bench|--backup|--report|--version|--help]"
            exit 0
            ;;
    esac
    
    main_menu
}

# Lancer le script
main "$@"
