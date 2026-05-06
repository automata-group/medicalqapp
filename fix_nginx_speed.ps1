$config = @"
# HTTP to HTTPS Redirect
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name healthlicenseprep.com www.healthlicenseprep.com;
    return 301 https://`$host`$request_uri;
}

# Main HTTPS Server
server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name healthlicenseprep.com www.healthlicenseprep.com;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Performance: Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;

    # Security Headers
    add_header X-Robots-Tag 'noindex, nofollow' always;

    # Cloudflare Real IP Logic
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 172.64.0.0/13;
    real_ip_header CF-Connecting-IP;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_read_timeout 90;
        proxy_connect_timeout 90;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
    }

    location /uploads/ {
        proxy_pass http://127.0.0.1:5000/uploads/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
    }

    # Caching for Static Assets (Fixing the 20-second delay)
    location /assets/ {
        proxy_pass http://127.0.0.1:8080/assets/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Buffer optimizations
        proxy_buffering on;
        proxy_buffers 8 16k;
        proxy_buffer_size 16k;

        expires 30d;
        add_header Cache-Control "public, no-transform";
        access_log off;
    }
}
"@

$config | ssh -o StrictHostKeyChecking=no -p 22022 root@209.74.82.107 "cat > /etc/nginx/sites-available/default && nginx -t && systemctl reload nginx"
