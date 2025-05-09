### 🔥 1. VPS Firewall Configuration

If your IPFS node is running on a VPS (e.g., Ubuntu):

#### ✅ Open these ports:

| Port | Protocol | Purpose                        |
| ---- | -------- | ------------------------------ |
| 4001 | TCP      | IPFS Swarm (peer connections)  |
| 4001 | UDP      | (Optional but recommended)     |
| 5001 | TCP      | IPFS API (local use only!)     |
| 8080 | TCP      | IPFS Gateway (to access files) |
| 443  | TCP      | (If you set up HTTPS Gateway)  |

#### 🧱 Example (UFW - Ubuntu Firewall):

```bash
sudo ufw allow 4001/tcp
sudo ufw allow 4001/udp
sudo ufw allow 8080/tcp
```

> ⚠️ **Don’t expose port 5001 (API)** to the public internet. Keep it bound to `127.0.0.1`.

---

### 🏠 2. Home Router Port Forwarding

If running your node at home, you need to:

#### ✅ Forward the following **from your router** to your machine's internal IP:

| External Port | Internal Port | Protocol | Purpose          |
| ------------- | ------------- | -------- | ---------------- |
| 4001          | 4001          | TCP      | Swarm connection |
| 4001          | 4001          | UDP      | Swarm (optional) |
| 8080          | 8080          | TCP      | Gateway access   |

#### ⚙️ How to do it:

1. Login to your router's admin panel.
2. Locate “Port Forwarding” or “NAT” section.
3. Add rules to forward those ports to your **local IP** (e.g., `192.168.1.50`).
4. Optionally, set a **static IP** for your device to prevent changes.

> 📌 Tip: Use [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) to check open ports from the outside.

---

### 🌐 Confirm It’s Working

1. Run on your IPFS node:

   ```bash
   ipfs id
   ```

   Look for multiaddrs with `/ip4/your_public_ip/tcp/4001` or `/ip6/...`.

2. Test from outside network:

   ```bash
   ipfs cat /ipfs/<CID>
   ```

   Or use:

   ```
   https://ipfs.io/ipfs/<CID>
   ```

---

Would you like a script to verify your public availability from a remote server or device?
