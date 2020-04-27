# SaasApp

Project management application with bootstrap on front-end.

### Features:

* User can sign up
* When registering, the user can select a tariff and create new project
* User as an admin can add other users to his project (by invitation link)
* All users within the project can add artifacts (stored in aws S3 bucket)
* At any time, the project administrator can change the tariff from free (one project can be managed) to premium (unlimited number of projects)
* Etc.

**Ruby & Rails version:**
- ruby 2.6.3
- rails 5.2.4.2

**Gems:**
- 'devise' for authentication
- 'devise-bootstrap-views' for pretty forms
- 'stripe' for access to the Stripe API (online payment processing)
- 'milia' for multi-tenanting support
- 'aws-sdk-s3' for uploading files to Amazon S3 bucket

https://glebson-saasapp.herokuapp.com/
