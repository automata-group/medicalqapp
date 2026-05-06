# Fix Firewall to allow all traffic on 80 and 443 (Diagnosing Cloudflare 522 error)
ssh -o StrictHostKeyChecking=no -p 22022 root@209.74.82.107 "ufw allow 80/tcp && ufw allow 443/tcp && ufw status"
