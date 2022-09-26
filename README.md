# Indy Email Verification Agent and Email Verification Service.
## How it's work

### Get Credentials

- First you should have a mobile wallet compatible for self sovering credentials.(eg: Trinsic Wallet)
- Go to credentials issuer website.
- Enter your email address and click submit.
- There will be a email containing a verification link.
- Click on the link.
- It will appier a QR code.
- Scan it from the wallet.
- It will appear a popup asking to accept or decline the request.
- Tap on Accept.
- Next you will have a notification. It is Credential Offer.
- Accept it to save given credentials in your wallet.
- Go to credentials in the mobile wallet and there will be your credentials.

### Present Credentials

 - To prescent credentials you should have credential. If not you have to fallow above steps to get one.
 - Goto the web page that you want to present your credentials.
 - Get the QR code by connecting to it.
 - Scan the QR code from the mobile wallet application.
 - There will be a popup asking for accept and decline.
 - Tap in accept to create connection between the web application and your mobile wallet.
 - After few seconds there will be a notification requesting proof of credentials.
 - Tap on that notification.
 - Select the credential that you want to present.
 - Tap on present to present the credentials.
 - Then automatically web page will receive the credentials that you present from your mobile.

## How to run local servers for development purposes

### Pre-Requisites

 - You should install `docker`, `docker-compose` and `s2i`.
 - Create a virtual environment
 - Install required libraries from `src/requirements.txt`.
 - Replace `AGENT_WALLET_SEED` in both `docker/manage` and `src/start.sh` files with unique id that should have 32 characters.
 - Important *
   - Use same id for both `docker/manage`, `src/start.sh` files.
   - Don't change it after first deployment.
 - Crete Postgres Database using below configurations
   - `DB_NAME=email_verification_db`
   - `DB_USER=admin`
   - `DB_PASSWORD="admin"`
   - `DB_PORT=5432`
   - `DB_HOST=localhost` or if you use existing database replace these values on `src/start.sh`
   
### Start Indy Email Verification Agent with docker.
 - Go to `docker` folder.
 - Open terminal from here there
 - Run `./manage build` for build the docker image.
 - When the build completes, run `./manage start` or `./manage up` for start  Email Verification Agent locally.

### Start Indy Email Verification Service without docker.
 - Go to `src` folder and open terminal from there.
 - run `./start.sh`

### Finally check server urls
 - `http://<Server-URL>:8080` will be your web server.
 - `http://<Server-URL>:10000` URL will use for the verification purposes.
 - `http://<Server-URL>:8050` will be the mail server. You can get your verification mail from this.