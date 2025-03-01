resource "aws_ses_email_identity" "verified_email" {
  email = var.default_email
}

# send email from your custom domain
# resource "aws_ses_domain_identity" "ses_domain" {
#   domain = "example.com"
# }

# resource "aws_ses_domain_dkim" "ses_dkim" {
#   domain = aws_ses_domain_identity.ses_domain.domain
# }

# resource "aws_ses_domain_mail_from" "ses_mail_from" {
#   domain           = aws_ses_domain_identity.ses_domain.domain
#   mail_from_domain = "mail.example.com"
# }