This module does two things:

1. Creates a domain and DNS records on DigitalOcean pointing at Vercel.
2. Configures the domains on Vercel.

By default, it fill follow the standard Vercel recommendations:

- `*.domain.com` will CNAME to Vercel, while apex `domain.com` will point to the Vercel's primary IP (76.76.21.21)
- `domain.com` will redirect to `www.domain.com`

If you configure `www` var to be `false`, the redirect will go in the opposite direction: `www.domain.com` -> `domain.com`.

Notes:

- Apex domain can't CNAME to Vercel, forbidden by RFCs
- we use DigitalOcean instead of Vercel for DNS hosting because Vercel Terraform provider doesn't allow domain creation when there's no project, and consistency is nice (won't want to manage more than one DNS provider)
- you can add extra DNS records with normal `resource "digitalocean_record"` blocks outside of this module
