## Connect to pinata.cloud peers:

```sh
curl -X POST "http://127.0.0.1:5001/api/v0/swarm/connect?arg=/dnsaddr/bitswap.pinata.cloud"
```

## Check if a given cid is locally

- Check block

```sh
curl -X POST "http://127.0.0.1:5001/api/v0/block/stat?arg=QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq"

{"Key":"QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq","Size":102}

```

- Check file and size

```sh
curl -X POST "http://127.0.0.1:5001/api/v0/dag/stat?arg=QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq"

{"TotalSize":102,"DagStats":[{"Cid":"QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq","Size":102,"NumBlocks":1}]}
{"TotalSize":262260,"DagStats":[{"Cid":"QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq","Size":262260,"NumBlocks":2}]}
{"TotalSize":270525,"DagStats":[{"Cid":"QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq","Size":270525,"NumBlocks":3}]}
{"UniqueBlocks":3,"TotalSize":270525,"Ratio":1,"DagStats":[{"Cid":"QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq","Size":270525,"NumBlocks":3}]}

```

- Check via local gateway:

```sh
http://127.0.0.1:8080/ipfs/QmcmALsN8rYXTV2xpXDzujPY93n5HVHCYT8Pat9nz5iePq
```

### ✅ Objective

Create a **Go program** that:

1. **Reads a `.jsonl` file** where each line contains metadata for an IPFS file including its `cid` and `name`.
2. **Checks** if each `cid` is already pinned in a local IPFS node.
3. **Pins** the `cid` if it’s not yet pinned.
4. Outputs a **summary report** listing:

   - ✅ Successfully pinned CIDs.
   - 🟢 Already pinned CIDs.
   - ❌ Failed pins (with error message).

---

### 📂 JSONL Input File: `all_files.jsonl`

Each line is a JSON object with at least:

```json
{
  "name": "file_name.jpg",
  "cid": "QmExampleHash123...",
  "size": 123456
}
```

Sample:

```json
{"name":"image1.jpg","cid":"QmA123...", "size":12345}
{"name":"image2.jpg","cid":"QmB456...", "size":67890}
```

---

### 🧩 Requirements

- Language: **Go**
- Use IPFS SDK: [`go-ipfs-api`](https://github.com/ipfs/go-ipfs-api)
- Interact with local IPFS daemon running at `localhost:5001`


---

### 🔌 Behavior Summary

For each line in the input:

1. Parse JSON to extract `cid` and `name`.
2. Call `/api/v0/pin/ls?arg=<cid>`:

   - If pinned → log as 🟢 already pinned.
   - If not found or error → attempt `/api/v0/pin/add?arg=<cid>`.

3. Log the result.
4. After all, print a summary of:

   - Total processed
   - Number pinned
   - Number already pinned
   - Number failed (with reasons)

---

### 🛠 Output Example

```
🟢 Already pinned: image1.jpg (QmA123...)
✅ Pinned successfully: image2.jpg (QmB456...)
❌ Failed to pin: image3.jpg (QmC789...) - Error: context deadline exceeded

--- Summary ---
Processed: 3
Already pinned: 1
Newly pinned: 1
Failed: 1
```

---

Would you like me to generate the actual Go code for this?

# Project structure

project-root/
│
├── pin_checker.go             # Your Go script
├── check_pinned_status.sh     # Bash script that generates pinning_report.txt
├── all_files.jsonl            # Input file
├── .env                       # Contains IPFS_API config
├── docker-compose.yml         # Orchestrates Go + IPFS
├── results/                   # Will hold pinning_report.txt (mapped as volume)
└── Dockerfile                 # Builds & runs the Go script + shell script
