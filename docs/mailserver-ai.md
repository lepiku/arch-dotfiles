# Docker Mailserver Guide: Setting Up a Private Email Server

## Background

I've purchased the domain `okuto.id` to create a private email service, moving away from free email providers like Gmail. The goal is to have full control over my domain's email infrastructure, ensuring privacy and reliability. This guide walks through setting up a Docker-based mail server using [Docker Mailserver](https://docker-mailserver.github.io/docker-mailserver/latest/), a lightweight, production-ready solution.

---

## Requirements

Before proceeding, ensure you have:

- Linux VPS with **Docker and Docker Compose** installed.
- A **public domain** (e.g., `okuto.id`) with DNS management access.
- Basic **Linux shell knowledge** (e.g., `curl`, `dig`), especially terminal text editors like `vim` or `nano`
- **Determination** to troubleshoot and configure the server.

---

## Docker Mailserver Overview

Docker Mailserver (DMS) is a lightweight, configuration-driven mail server that supports SMTP, IMAP, POP3, SPF, DKIM, DMARC, and more. It avoids databases, using plain text configuration files instead.

**Key Features**:

- No SQL database required.
- Supports anti-spam (SpamAssassin), anti-virus (ClamAV), and LDAP.
- Easy to customize via environment variables and config files.

[Official Documentation](https://docker-mailserver.github.io/docker-mailserver/latest/)

---

## Steps to Setup Docker Mailserver

### 1. **Preliminary DNS Configuration**

#### a. **MX Records**

An **MX (Mail Exchange) record** directs email traffic to your mail server(s).
When an email is sent to your domain, the recipient’s server uses DNS to find
the **MX record(s)**, which list the mail servers (by IP or hostname)
authorized to receive emails **Priority values** (lower numbers first) ensure
redundancy and failover.
Properly configuring **MX records** and **PTR (reverse DNS) records** is critical to avoid delivery issues and spam filtering.

##### Examples

Example 1:

| Domain | TTL   | Class | Type | Priority | Destination     |
| ------ | ----- | ----- | ---- | -------- | --------------- |
| `@`    | 14400 | IN    | A    |          | `103.52.114.26` |
| `@`    | 14400 | IN    | MX   | 10       | `okuto.id`      |

Example 2:

| Domain | TTL   | Class | Type | Priority | Destination     |
| ------ | ----- | ----- | ---- | -------- | --------------- |
| `@`    | 14400 | IN    | A    |          | `103.52.114.26` |
| `mail` | 14400 | IN    | A    |          | `11.22.33.44`   |
| `@`    | 14400 | IN    | MX   | 10       | `mail.okuto.id` |

##### Test MX Record (example 1)

Test your DNS config with `dig` command:

```bash
dig @1.1.1.1 +short MX okuto.id.
# 10 okuto.id

dig @1.1.1.1 +short A okuto.id
# 103.52.114.26
```

> Note: check expected output after the hashtag (`#`)

#### b. **PTR Records (Reverse DNS)**

PTR records map an IP to a domain name. This is critical for email delivery to avoid rejection by spam filters.

##### Request from VPS Provider

A **PTR record (Reverse DNS)** maps an IP address to a domain name, ensuring that the server's IP matches its hostname.
This is critical for email servers, as many mail systems validate the valid PTR record to **prevent being marked as spam and ensure authenticity**.
If your VPS provider doesn't allow manual PTR setup, you must request them to create it, specifying the **domain name** (e.g., `okuto.id`) and the **server's IP address** (e.g., `103.52.114.26`).
Always verify the PTR record using tools like `dig` to confirm it resolves to the expected domain.

Here is a simple template to ask for a PTR record creation:

```txt
Dear [VPS Provider Support Team/Name],

I hope this message finds you well. I am reaching out to request the creation of a PTR (Reverse DNS) record for my VPS server. This is necessary to ensure proper email server functionality and deliverability.

Details:
    IP Address: [Your VPS IP, e.g., 103.52.114.26]
    Domain Name: [Your domain, e.g., okuto.id]

Thank you for your assistance!

Best regards,
[Your Full Name]
[Your Contact Information, if needed]
[Your VPS Account Details, if applicable]
```

**Test PTR Record**:

```bash
dig @1.1.1.1 +short -x 103.52.114.26
# okuto.id
```

---

### 2. **Deployment Steps**

[Official Documentation](https://docker-mailserver.github.io/docker-mailserver/latest/usage/#deploying-the-actual-image)

#### a. **Create Project Directory**

```bash
mkdir -p /opt/mailserver/data
cd /opt/mailserver
```

#### b. Create `docker-compose.yml`

```yaml
services:
  mailserver:
    image: mailserver/docker-mailserver:15
    hostname: okuto.id
    container_name: mailserver
    ports:
      - "25:25" # SMTP
      - "143:143" # IMAP
      - "587:587" # Submission
      - "993:993" # IMAPS
      - "465:465" # SMTPS
    volumes:
      - ./data:/var/mail
      - ./config:/etc/mailserver
    environment:
      - MAIL_DOMAIN=okuto.id
      - MAIL_USER=okuto
      - MAIL_PASSWORD=your_password
      - ENABLE_SPAMASSASSIN=1
      - ENABLE_CLAMAV=1
    restart: unless-stopped
```

**Explanation**:

- `MAIL_DOMAIN`: Your domain name.
- `MAIL_USER`: A test email address (e.g., `okuto@okuto.id`).
- `ENABLE_SPAMASSASSIN`/`ENABLE_CLAMAV`: Enables spam and virus filtering.

#### c. **Start the Container**

```bash
docker-compose up -d
```

**Verify Logs**:

```bash
docker logs mailserver
```

---

### 3. **Security Improvements**

#### a. **SPF, DKIM, DMARC Records**

Add these to your DNS for email authentication:

- **SPF**:

  ```
  v=spf1 mx -all
  ```

- **DKIM**:  
  Generate a DKIM key:

  ```bash
  docker exec -it mailserver opendkim-genkey -s default -d okuto.id
  ```

  Add the public key to DNS:

  ```
  default._domainkey IN TXT "v=DKIM1; k=rsa; p=..."
  ```

- **DMARC**:
  ```
  _dmarc IN TXT "v=DMARC1; p=none; rua=mailto:admin@okuto.id"
  ```

#### b. **SSL/TLS with Let's Encrypt**

Install [Certbot](https://certbot.eff.org/) to secure your server.

#### c. **Firewall Rules**

Restrict access to SMTP/IMAP ports:

```bash
ufw allow from [your_ip] to any port 25,143,587,993
ufw deny 25/tcp
```

#### d. **Regular Backups**

Back up the `data` and `config` directories:

```bash
tar -czf mailserver_backup.tar.gz ~/mailserver/data ~/mailserver/config
```

---

## Troubleshooting Tips

- **DNS Propagation**: Wait 24–48 hours for DNS changes to take effect.
- **Email Not Receiving**: Check `mail.log` in the container:
  ```bash
  docker exec -it mailserver tail -f /var/log/mail.log
  ```
- **Firewall Issues**: Ensure ports 25, 587, 993 are open.

---

## Conclusion

By following this guide, you now have a secure, self-hosted email server using Docker Mailserver. This setup provides full control over your domain’s email, enhancing privacy and reliability. For advanced configurations, explore the [DMS documentation](https://docker-mailserver.github.io/docker-mailserver/latest/).

**Note**: Always keep your server updated and monitor logs for security threats.
