# Mailserver

How to setup a mail server with `docker-mailserver`.

## Background

I have bought a domain `okuto.id`, and I want to make my emails more private.
I want to move away from free mail services like [Gmail](https://gmail.com).
Later, I would have a very short email and full control of my emails (and other emails in my domain)

## Requirements

- Knowledge to use [`docker`](https://www.docker.com) and `docker compose`
- A Linux VPS (with `docker` installed)
- A public domain (my example is [`okuto.id`](https://okuto.id))
- Basic linux shell command
- Determination and desire to learn

## Docker Mailserver

Reference: <https://docker-mailserver.github.io/docker-mailserver/latest/>

> docker-mailserver, or DMS for short, is a production-ready fullstack but
> simple mail server (SMTP, IMAP, LDAP, Anti-spam, Anti-virus, etc.). It
> employs only configuration files, no SQL database. The image is focused
> around the slogan "Keep it simple and versioned".
>
> [Source](https://docker-mailserver.github.io/docker-mailserver/latest/#about)

I'm looking for a lightweight mail server that can run inside docker.
To learn more, read the [introduction](https://docker-mailserver.github.io/docker-mailserver/latest/introduction/).

## Steps

This guide contain multiple stages:

- Preliminary Steps
- Deployment Steps
- Security Improvement Steps

### Preliminary Steps

Reference: <https://docker-mailserver.github.io/docker-mailserver/latest/usage/#preliminary-steps>

#### 1. MX Record

First, I need to setup my DNS records so that I when someone sends an email to
you, they know where they should send them.

If you already have and `A` record, it's not enough for mail server. Why?
So you can still receive email in case a server goes down.

Go to the website where you manage your domain. Look for `DNS Management` menu.

Examples:

> Note: @ Domain on the table means no subdomain, just okuto.id

1. I have only 1 server: okuto.id. (The setup I use)

   | Domain |   TTL | Class | Type | Priority | Destination   |
   | ------ | ----: | :---: | :--: | :------: | ------------- |
   | @      | 14400 |  IN   |  A   |          | 103.52.114.26 |
   | @      | 14400 |  IN   |  MX  |    10    | okuto.id      |

2. My mail server on another IP: 11.22.33.44.
   I need to set a domain name for that IP (example: mail.okuto.id)

   **Create domain A record (for example `mail`). and point the MX record to it.**

   | Domain |   TTL | Class | Type | Priority | Destination   |
   | ------ | ----: | :---: | :--: | :------: | ------------- |
   | mail   | 14400 |  IN   |  A   |          | 11.22.33.44   |
   | @      | 14400 |  IN   |  MX  |    10    | mail.okuto.id |

3. I have multiple mail servers running.

   **Use multiple Priority.**

   Email will be sent in order from smallest to largest priority.

   | Domain |   TTL | Class | Type | Priority | Destination  |
   | ------ | ----: | :---: | :--: | :------: | ------------ |
   | mx1    | 14400 |  IN   |  A   |          | 11.22.33.44  |
   | mx2    | 14400 |  IN   |  A   |          | 55.66.77.88  |
   | @      | 14400 |  IN   |  MX  |    10    | mx1.okuto.id |
   | @      | 14400 |  IN   |  MX  |    20    | mx2.okuto.id |

   > Note: I will not cover how to manage multiple mail server in this guide.

##### Test: MX Record

Use `dig` shell command.

```sh
$ dig @1.1.1.1 +short MX [domain]
[MX record destination]
$ dig @1.1.1.1 +short A [MX record destination]
[A record destination]
```

If I use the second example, it should be:

```sh
$ dig @1.1.1.1 +short MX okuto.id
mail.okuto.id
$ dig @1.1.1.1 +short A mail.okuto.id
11.22.33.44
```

#### 2. PTR Record

PTR Record is ...

My VPS provider does not allow me to manually create a PTR record. Then I asked
my provider to create A PTR record. They direct me to create a support ticket.
Here's my ticket content in general.

> Hello [VPS Provider],
>
> I want to create a mail server on the VPS. I need a PTR record. Please create
> it for me. Here are the details:
>
> IP: [103.52.114.26]
> Destination: okuto.id
>
> Thank you.
>
> Regards,
> Okuto

After a few minutes, they responded and a PTR record have been created.

##### Test: PTR Record

Use `dig` shell command.

```sh
$ dig @1.1.1.1 +short -x [A record destination]
[domain]
```

If I use the second example, it should be:

```sh
$ dig @1.1.1.1 +short -x 11.22.33.44
mail.okuto.id
```

### Deployment Steps

```sh
# SSH to the VPS
ssh okuto.id

# cd to any directory you want to store mailserver configs and data
# example: /opt/server/mailserver
mkdir -p /opt/server/mailserver
cd /opt/server/mailserver
```
