# Deploy and Host Apache Guacamole on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/guacamole?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=guacamole)

Apache Guacamole is a clientless remote desktop gateway: it puts your RDP, VNC, SSH and Telnet machines in a browser tab, with nothing to install on the computer you connect from. This template runs it on Railway as its three parts, the Guacamole web app, the guacd proxy that speaks the remote protocols, and PostgreSQL for users and connections, with the admin login set from variables.

This is a community template, not made or supported by the Apache Software Foundation.

## About Hosting Apache Guacamole

A Guacamole set up by the book needs its database schema loaded by hand, and then ships with the well-known login `guacadmin` / `guacadmin` until someone changes it. This template does both before the app goes online: on the first boot it creates the schema and renames that account to `ADMIN_USERNAME` with the generated `ADMIN_PASSWORD`.

It also:

- serves Guacamole at the root of your domain instead of `/guacamole/`
- reads the real client address from Railway's proxy, so Guacamole's ban on repeated failed logins blocks the attacker, not everyone behind the proxy
- connects the three services over Railway's private network; only the web app is public

**Log in:** open the Guacamole service's domain and sign in with `ADMIN_USERNAME` and the `ADMIN_PASSWORD` from its Variables tab. Then go to **Settings > Connections > New Connection** and add a machine.

## Common Use Cases

- Reach servers and desktops from any browser, including locked-down work laptops and Chromebooks
- One gateway with per-user access to many machines, instead of handing out SSH keys and RDP files
- Remote support and lab access without a VPN client

## Dependencies for Apache Guacamole Hosting

- Machines to connect to that Railway can reach: on the public internet, or on your network through a tunnel or VPN

### Deployment Dependencies

- [Guacamole manual](https://guacamole.apache.org/doc/gug/)
- [apache/guacamole-client](https://github.com/apache/guacamole-client)
- [Template source](https://github.com/two-workspaces/guacamole)

### Implementation Details

- **Tested on Railway:** PENDING
- **Variables after the first boot:** `ADMIN_USERNAME` and `ADMIN_PASSWORD` are read once. Change the password in Guacamole's settings afterwards; editing the variables does nothing.
- **Memory:** PENDING
- **Images:** the web app is `ghcr.io/two-workspaces/guacamole`, built from this repository's Dockerfile on `guacamole/guacamole:1.6.0` with `postgresql-client` added for the first-boot setup; guacd is the official `guacamole/guacd:1.6.0`.

## Why Deploy Apache Guacamole on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Apache Guacamole on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
