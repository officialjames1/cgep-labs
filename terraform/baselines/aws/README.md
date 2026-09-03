# One major detail that must be noted is when the test ran earlier, the config file was initially absent and flagged a critical finding. However,
# with the ConfigFile permission I added to the IAM account in AWS and not the root account, when I came back about 3 hours later, the status changed to passed.
# This happened as a result of creating a test recorder initially to do some investigative work which made Security Hub detect a compliant Config state for a brief window of time.
# As the conclusion for this particular lab, Config should not be running due to the cleanup associated with closing this work out.

# Security Controls
# Cloudtrail.tf file should demonstrate the following CTRLs: AU-2/AU-12/AU-10
# Security_hub.tf file should demonstrate CTRLs: RA-5/SI-4
# AWS Config is interesting to note because as previously mentioned in the introductory write up, the account state is not the same as when it was originally ran. However, I will still list the CTRLs here: CM-2/CM-6/CM-8