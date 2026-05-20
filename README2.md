# Projekt 4: Säker Filserverinfrastruktur (IaC)

> En automatiserad infrastruktur som sätter upp ett säkert filserversystem via NFS mellan två Ubuntu-maskiner med hjälp av Vagrant och Ansible, med implementerad rollbaserad åtkomstkontroll.

---

## Innehållsförteckning

- [Arkitektur](#arkitektur)
- [Miljöer och IP-adresser](#miljöer-och-ip-adresser)
- [Mappstruktur](#mappstruktur)
- [Komponenter](#komponenter)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Secrets](#secrets)
- [Säkerhetsåtgärder](#säkerhetsåtgärder)
- [Säkerhetsanalys](#säkerhetsanalys)
- [Verifiering](#verifiering)
- [Designval och motivering](#designval-och-motivering)

---

## Arkitektur

Miljön bygger på två virtuella maskiner som kommunicerar över ett isolerat privat nätverk. Servern agerar "arkivskåp" och delar ut mappar, medan klienten monterar dessa mappar lokalt.

Windows-laptop (Host)
        |
┌───────▼────────────────────────────────────────┐
│           Privat nätverk 192.168.50.0/24       │
│                                                │
│  ┌─────────────────────┐                       │
│  │   fileserver        │                       │
│  │   192.168.50.10     │  <-- NFS-tjänst       │
│  │   (Ubuntu 22.04)    │                       │
│  └────────┬────────────┘                       │
│           │ Utdelade mappar:                   │
│           │ /shares/avdelning-a (Låst: 0770)   │
│           │ /shares/avdelning-b (Låst: 0770)   │
│           │                                    │
│           │ (NFS-protokoll)                    │
│           ▼                                    │
│  ┌─────────────────────┐                       │
│  │   client            │                       │
│  │   192.168.50.11     │  <-- Monterar i /mnt/ │
│  │   (Ubuntu 22.04)    │                       │
│  └─────────────────────┘                       │
└────────────────────────────────────────────────┘

---

## Miljöer och IP-adresser

| Miljö | Hostname | IP-adress | OS | Roll |
|---|---|---|---|---|
| Server | fileserver | 192.168.50.10 | Ubuntu 22.04 | Agerar NFS-server, hanterar grupper och fillåsningar. |
| Klient | client | 192.168.50.11 | Ubuntu 22.04 | Arbetsstation som monterar serverns mappar via NFS. |

---

## Mappstruktur

Fil-Server-Infrastruktur/
├── Vagrantfile              # Definierar alla VMs, nätverksinställningar och provisionering
│
├── ansible/
│   ├── fileserver.yml       # Konfigurerar NFS servern, skapar mappar, användare och rättigheter
│   └── klient_montering.yml # Installerar NFS klientverktyg och monterar upp nätverksmapparna
│
├── verifiering.sh           # Automatiserat Bash skript för säkerhetstestning
└── README.md                # Denna dokumentation

---

## Komponenter

### Vagrantfile
Definierar två virtuella maskiner i VirtualBox med ett gemensamt nätverk 192.168.50.0/24. Använder provisionern ansible_local för att automatiskt installera Ansible inuti Ubuntu-maskinerna och köra konfigurationen därifrån, vilket rundar begränsningar med Ansible på Windows.

### Ansible Playbooks (Beyars & Jacobs delar)
* fileserver.yml: Backend-konfigurationen. Installerar nfs-kernel-server, skapar mappstrukturen, exporterar dessa till klienten och hanterar identiteter skapar grupper, användare och applicerar 0770-rättigheter.
* klient_montering.yml: Frontend-konfigurationen. Installerar nfs-common och använder Ansibles mount-modul för att fästa serverns nätverksmappar till klientens lokala filsystem.

### Verifieringsskript (verifiering.sh)
Ett Bash skript framtaget för att bevisa att säkerhetsimplementationen fungerar. Skriptet simulerar användaren jacob_a och testar åtkomsten för att verifiera att behörighetskontrollen 0770 stoppar obehöriga anrop.

---

## Krav och förutsättningar

För att kunna driftsätta denna miljö krävs följande på host-maskinen (Windows):
- VirtualBox (Hypervisor)
- Vagrant (Orkestrering av VMs)
- Git Bash / PowerShell

---

## Kom igång

Så här bygger och startar du upp hela infrastrukturen:

1. Klona projektet:
git clone <https://github.com/BeyarSWE/Fil-Server-Infrastruktur>
cd Fil-Server-Infrastruktur

2. Bygg miljön:
vagrant up
Detta startar maskinerna, installerar Ansible och konfigurerar nätverk och säkerhet automatiskt.

3. Verifiera säkerheten:
vagrant ssh client -c "bash /vagrant/verifiering.sh"

---

## Secrets

I detta specifika projekt hanteras inga känsliga API nycklar eller databaslösenord som kräver verktyg som ansible-vault. Säkerheten för själva infrastrukturen bygger istället på Vagrants automatiskt genererade SSH nycklar för kommunikation mellan host och virtuella maskiner.

---

## Säkerhetsåtgärder

Följande säkerhetsåtgärder är implementerade via Ansible:
* Katalogrättigheter 0770: Endast ägaren och den specifika gruppen får läsa, skriva och exekvera. Andra användare har noll tillgång.
* Dedikerade Grupper RBAC: Istället för att ge rättigheter till enskilda individer används grupper (t.ex. grupp_a), vilket gör systemet skalbart.
* Isolerat Nätverk: Trafiken går över ett privat 192.168.50.X nätverk som inte är exponerat direkt mot internet.

---

## Säkerhetsanalys

Under projektets gång genomförde vi en hotmodellering och identifierade följande brister i vår miljö samt hur de hanteras i produktion:

### Okrypterad nätverkstrafik och Man-in-the-Middle (MitM)
Ett hot vi ansåg var aktuellt gällande NFS är att det normalt skickas data i klartext. Eftersom standard NFS saknar inbyggd kryptering finns det en risk för att en man in the middle attack träder fram, vilket i detta fall kan leda till att trafiken avlyssnas. Vi löste det genom att hänvisa till IPsec och VPN. Inom produktionen hade vi i detta fall hanterat det genom att skydda kommunikationen med hjälp av VPN och IPsec.

### Brist på Redundans (SPOF)
Vår nuvarande miljö består av en ensam filserver. Riktiga företag är i bruk av High Availability. Om vår server kraschar förlorar alla åtkomst direkt, till skillnad från företag som använder HA kluster för att säkerställa att en annan server automatiskt tar över vid driftstopp.

---

## Verifiering

För att testa miljön körs kommandot vagrant ssh client -c "bash /vagrant/verifiering.sh". Detta loggar in på klienten och kör testet. 

Förväntat resultat där säkerheten blockerar otillåtna försök och tillåter godkända:

📂 TEST 1: Försöker skriva till Avdelning A...
👤 Agerar som: jacob_a
✅ RESULTAT: LYCKADES! Jacob kan skriva i sin egen mapp.

🔒 TEST 2: Försöker skriva till Avdelning B...
👤 Agerar som: jacob_a
✅ RESULTAT: LYCKADES! Åtkomst nekad - Säkerheten fungerar.

---

## Designval och motivering

### Varför Ansible Local istället för Remote?
Eftersom vi utvecklade på Windows-maskiner kunde Ansible inte köras som Control Node lokalt. För att undvika komplicerade WSL installationer valde vi att använda ansible_local. Detta installerar automatiskt Ansible inuti Ubuntu-maskinerna och gör vår IaC 100 % plattformsoberoende.

### Varför NFS framför SMB?
Eftersom vår miljö strikt består av Ubuntu Linux var NFS det mest logiska valet. Det är native för Linux system, ger snabbare prestanda för maskin till maskin kommunikation och hanterar Linux specifika filrättigheter bättre än vad SMB/CIFS gör.

### Varför LF-radbrytningar (Line Endings)?
Under utvecklingen av vårt Bash skript i Windows stötte vi på problemet $'\r': command not found. Detta berodde på osynliga Windows radbrytningar (CRLF). Vårt designval blev att strikt konvertera script filerna till Linux standard (LF) i VS Code för att säkerställa att de körs felfritt via Vagrant.

---
### Kurs: Virtualiseringsteknik & Automation
#### Skapad av: Beyar & Jacob
### år: 2026-05-20
