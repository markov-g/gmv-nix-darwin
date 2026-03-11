# Secrets — sops-nix Guide

Secrets are encrypted with [sops](https://github.com/getsops/sops) using an
[age](https://age-encryption.org) key derived from your SSH key.
The encrypted `secrets.yaml` is **safe to commit**. The plaintext never touches disk
(sops-nix decrypts to a tmpfs path at activation time).

---

## How it works

```
SSH private key (~/.ssh/id_ed25519)
        │
        │  ssh-to-age
        ▼
age private key (~/.config/sops/age/keys.txt)   ← stays on disk, never committed
        │
        │  age-keygen -y   (derive public key)
        ▼
age public key  →  .sops.yaml  →  encrypt secrets.yaml  →  commit ✓
        │
        │  sops-nix (at darwin-rebuild switch)
        ▼
decrypted files at runtime paths:
  ~/.netrc          (mode 0600)
  ~/.aws/credentials
  ~/.docker/config.json
  ~/.kube/config
  ~/.ssh/id_ed25519
  ~/.ssh/id_ed25519.pub
```

**Key files:**
| File | Purpose | Committed? |
|------|---------|-----------|
| `.sops.yaml` | Tells sops which age key to use for encryption | ✅ Yes |
| `secrets/secrets.yaml` | Encrypted secrets (safe to commit) | ✅ Yes |
| `~/.config/sops/age/keys.txt` | Your age private key | ❌ Never |

---

## First-time setup on a new machine

### Prerequisites
`age`, `ssh-to-age`, and `sops` are available as Nix packages after `darwin-rebuild switch`.
On a brand-new machine (before first switch), install them temporarily:
```bash
nix-env -iA nixpkgs.age nixpkgs.ssh-to-age nixpkgs.sops
# or via Homebrew if nix isn't set up yet:
brew install age ssh-to-age sops
```

### Step 1 — Generate your age key from your SSH key

```bash
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

> **Why derive from SSH?**  You already back up your SSH key. Deriving the age key
> from it means one fewer secret to manage — if you restore your SSH key, you can
> always re-derive the age key with the same command.

### Step 2 — Get the age PUBLIC key

```bash
age-keygen -y ~/.config/sops/age/keys.txt
# output: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Copy that output. It is safe to share / commit.

### Step 3 — Update `.sops.yaml`

Edit `~/.config/nix-darwin/.sops.yaml` and replace the placeholder:
```yaml
- &r1pp3r_age age1REPLACE_WITH_YOUR_AGE_PUBLIC_KEY
```
→
```yaml
- &r1pp3r_age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Commit this change — it contains only the public key.

### Step 4 — Create `secrets/secrets.yaml`

```bash
cd ~/.config/nix-darwin
sops secrets/secrets.yaml
```

This opens `$EDITOR` (nvim) with an empty YAML template. Fill in your secrets:

```yaml
netrc: |
  machine api.github.com login YOUR_GITHUB_USER password ghp_YOURTOKEN
  machine github.com      login YOUR_GITHUB_USER password ghp_YOURTOKEN

aws_credentials: |
  [default]
  aws_access_key_id = AKIAIOSFODNN7EXAMPLE
  aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  region = eu-central-1

docker_config: |
  {
    "auths": {
      "ghcr.io": { "auth": "base64encodeduser:token" }
    }
  }

kube_config: |
  apiVersion: v1
  kind: Config
  clusters: []
  contexts: []
  users: []

ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  paste your full private key here
  -----END OPENSSH PRIVATE KEY-----

ssh_public_key: "ssh-ed25519 AAAAC3Nza... user@host"
```

Save and quit (`ZZ` or `:wq`). sops encrypts the file on write.

### Step 5 — Apply and verify

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
# sops-nix decrypts secrets to their runtime paths at activation

# Verify:
ls -la ~/.netrc ~/.aws/credentials ~/.ssh/id_ed25519
# Should show mode 0600, owned by you
```

---

## Day-to-day operations

### Edit an existing secret

```bash
sops ~/.config/nix-darwin/secrets/secrets.yaml
# Opens in $EDITOR; decrypted in memory only. Saves re-encrypted.
```

### Add a new secret

1. Add the key to `secrets.yaml` via `sops secrets/secrets.yaml`
2. Add a corresponding entry in `home.nix`:
```nix
sops.secrets."my_new_secret" = {
  path = "${config.home.homeDirectory}/.my-secret-file";
  mode = "0600";
};
```
3. `darwin-rebuild switch`

### Migrate to a new machine

On the new machine:
1. Restore `~/.ssh/id_ed25519` (from backup or sops secrets on old machine)
2. Re-run steps 1–5 above — **the `.sops.yaml` public key stays the same** as long as you use the same SSH key
3. `darwin-rebuild switch` decrypts everything

### Add a second machine / user

Each person/machine needs their own age key. Edit `.sops.yaml`:
```yaml
keys:
  - &r1pp3r_age  age1xxxxxxxxxxxxxxxxxxxxxxxx   # minidevbox
  - &macbook_age age1yyyyyyyyyyyyyyyyyyyyyyyyyy  # macbook

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *r1pp3r_age
          - *macbook_age
```

Then re-encrypt: `sops updatekeys secrets/secrets.yaml`

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `could not find a suitable key` | `~/.config/sops/age/keys.txt` missing | Re-run Step 1 |
| `mac verify failed` | Wrong age key (different SSH key) | Check which SSH key you used |
| `secrets.yaml not found` | File doesn't exist yet | Run Step 4 |
| Secrets not decrypted after switch | `pathExists` guard active (file exists but sops config wrong) | Check `.sops.yaml` has correct public key |
| `permission denied` on secrets file | File owned by root (launchd wrote it) | `darwin-rebuild switch` re-activates ownership |
