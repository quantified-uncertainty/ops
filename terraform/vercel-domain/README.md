This module does two things:

1. Creates a domain and DNS records on DigitalOcean pointing at Vercel.
2. Configures the domains on Vercel.

By default, it fill follow the standard Vercel recommendations:

- `www.domain.com` will redirect to `domain.com`
- `*.domain.com` will CNAME to Vercel, while apex `domain.com` will point to the Vercel's primary IP (76.76.21.21)

Notes:

- Apex domain can't CNAME to Vercel, forbidden by RFCs
- we use DigitalOcean instead of Vercel for DNS hosting because Vercel Terraform provider doesn't allow domain creation when there's no project, and consistency is nice (won't want to manage more than one DNS provider)
- you can add extra DNS records with normal `resource "digitalocean_record"` blocks outside of this module
