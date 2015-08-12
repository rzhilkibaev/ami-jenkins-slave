#!/usr/bin/env bash

set -e
set -o pipefail

if [ -f setenv.sh ]; then
    source setenv.sh
    packer build \
        -var "aws_account_id=$ACCOUNT_ID" \
        -var "aws_access_key=$ACCESS_KEY" \
        -var "aws_secret_key=$SECRET_KEY" \
        -var "aws_x509_cert_path=$X509_CERT_PATH" \
        -var "aws_x509_key_path=$X509_KEY_PATH" \
        -var "aws_region=$REGION" \
        -var "aws_source_ami=$SOURCE_AMI" \
        ami-jenkins-slave.json
    exit 0
fi

cat > setenv.sh <<"EOL"
ACCOUNT_ID=""
ACCESS_KEY=""
SECRET_KEY=""
# openssl req -new -x509 -nodes -sha1 -days 9999 -key my-aws-signing-cert-private-key.pem -outform PEM > my-aws-signing-cert.pem
X509_CERT_PATH=""
# openssl genrsa 1024 > my-signing-cert-private-key.pem
X509_KEY_PATH=""
REGION=""
# ami-598f711d us-west-1 ubuntu trusty 14.04 hvm-is
SOURCE_AMI=""
EOL

echo "Populate setenv.sh"

