# Email DNS records for Resend
# These records enable email sending from noreply@roastmypost.org

resource "digitalocean_record" "email_resend" {
  for_each = {
    "mx" : {
      type  = "MX"
      name  = "send"
      value = "feedback-smtp.us-east-1.amazonses.com."
    },
    "spf" : {
      type  = "TXT"
      name  = "send"
      value = "v=spf1 include:amazonses.com ~all"
    },
    "dkim" : {
      type  = "TXT"
      name  = "resend._domainkey"
      value = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+JurwC2nD+DzsvEAGG1h453ifbKoBUQPvjOeEre/muaqifQdOs7cMmm/JTgrS6rzX3JgzIl0uh5ju16PnGFF1XVElvWA/YiI9yvSk2c+MTEVJIXWPHU3rMabIeS5gk0NcLA8vIJPtA5ptELCkEHJY5dGw0+paFW+z97onnWb6XwIDAQAB"
    },
    "dmarc" : {
      type  = "TXT"
      name  = "_dmarc"
      value = "v=DMARC1; p=none;"
    }
  }

  domain   = local.domain
  name     = each.value.name
  type     = each.value.type
  ttl      = 300
  priority = each.value.type == "MX" ? 10 : null
  value    = each.value.value
}