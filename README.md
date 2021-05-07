# Minikube and Let's Encrypt 
This repository contains sources for a related 
[medium.com](https://medium.com/@klaushofrichter/minikube-and-lets-encrypt-6e407aabb8ac) article with more details. 
It explains how to connect a local Minikube cluster to the public Internet and generate
a Let's Encrypt certificate. 

To use the shell script directly, change the first few environment variables to meet your needs:

```
export PUBLICURL="your.domain.com"
export CERTLEVEL="stage"  # use "stage" or "prod"
export EMAIL="your.email@emailprovider.com"
```

After adjusting the variables above in the script, call it and wait for 10 minutes... you may 
have a certificate generated that can be reused :-) Checkout details at [medium.com](https://medium.com/@klaushofrichter/minikube-and-lets-encrypt-6e407aabb8ac).

## Prerequisites
* A domain name that you control and that can map to your network.
* A Linux PC with Ubuntu 20.04.  
* Minikube version 1.19+ or better.
* virtualbox.

## Updates
* May 7, 2021: There is a followup repository available [here](https://github.com/klaushofrichter/Minikube-and-OAuth2) that shows 
  how to add OAuth2 authentication to this Kubernetes application.
