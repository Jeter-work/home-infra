Great setup! Let me address each part of your infrastructure migration:

## **Current Project - DNS/DHCP Status**

✅ **DHCP is already included** in your Pi-hole setup! The Ansible playbook configures both DNS filtering and DHCP services in the same container.

**DHCP Configuration in your current setup:**
- Home: 192.168.86.100-200
- Homelab: 192.168.86.50-99

## **Google Nest + UniFi VLAN Implementation**

### **Challenge with Google Nest:**
**Google Nest routers don't support VLANs.** They're consumer-grade devices designed for simplicity, not enterprise networking features.

### **Your Options:**

#### **Option 1: Replace Google Nest (Recommended)**
- **pfSense** or **OPNsense** VM on Proxmox
- **UniFi Dream Machine** or **Dream Router**
- **Dedicated firewall appliance**

#### **Option 2: Work Around Nest Limitations**
- Use **port-based VLANs** on UniFi switch
- Keep Google Nest as "dumb" access point only
- Route VLANs through Proxmox or separate router

## **UniFi Switch VLAN Configuration**

### **Manual Configuration (Web UI)**
Since the US-16-150W is Layer 2 only, you'll configure VLANs via UniFi Controller:

1. **Install UniFi Network Controller** (can be containerized)
2. **Adopt the switch**
3. **Create VLAN profiles**
4. **Assign ports to VLANs**

### **Ansible for UniFi (Limited)**
**Unfortunately:** UniFi Network switches have limited Ansible support. The official UniFi modules are mainly for wireless, not switching.

**Available options:**
- **community.network.unifi** collection (limited)
- **API calls** via ansible.builtin.uri module
- **Custom scripts** with UniFi API

Let me show you both approaches:

Now let me create an updated network architecture plan:

Now let me create VLAN-aware OpenTofu modules:

## **Summary & Recommendations**

### **✅ Your Current Project Already Includes DHCP**
Pi-hole handles both DNS filtering AND DHCP services in the same container. The Ansible playbook configures both automatically.

### **🔧 UniFi Switch + Google Nest Strategy**

#### **Immediate Steps:**
1. **Install UniFi switch** with basic VLAN configuration
2. **Keep Google Nest** as gateway but disable its DHCP/DNS
3. **Use Proxmox containers** for DNS/DHCP per VLAN
4. **Work around Nest VLAN limitations** with port-based VLANs

#### **Future Migration Path:**
Replace Google Nest with UniFi Dream Machine or pfSense for full VLAN support

### **📋 Implementation Priority:**

1. **Phase 1** (This project): Get DNS/DHCP containers working on flat network
2. **Phase 2**: Install UniFi switch and controller
3. **Phase 3**: Create VLANs and migrate gradually
4. **Phase 4**: Replace Google Nest when ready

### **🚫 Ansible for UniFi Limitation**
UniFi switches have limited Ansible support. You'll likely need to configure VLANs manually through the UniFi Controller web interface.

### **🎯 Recommended Next Steps:**

1. **Complete your current DNS/DHCP project** first
2. **Install UniFi Controller** (preferably on Proxmox)
3. **Plan VLAN migration** using the artifacts above
4. **Test with homelab VLAN** before moving family devices

Would you like me to:
1. **Focus on completing the current flat network setup** first?
2. **Create UniFi Controller deployment scripts** for Proxmox?
3. **Design the inter-VLAN routing configuration** for Proxmox?

The VLAN migration is definitely doable, but it's a significant project that's best tackled after your current DNS/DHCP infrastructure is solid.