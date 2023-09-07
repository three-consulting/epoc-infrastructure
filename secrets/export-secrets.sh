if [ $1 = "dev" ] || [ $1 = "prod" ]; then 
    export TF_VAR_FIREBASE_SERVICE_ACCOUNT_JSON=$(gopass show --password 3/epoc/firebase/$1/FIREBASE_SERVICE_ACCOUNT_JSON) &&
    export TF_VAR_SPRING_DATASOURCE_PASSWORD=$(gopass show --password 3/epoc/db/$1/SPRING_DATASOURCE_PASSWORD)
    export TF_VAR_SPRING_DATASOURCE_USERNAME=$(gopass show --password 3/epoc/db/$1/SPRING_DATASOURCE_USERNAME)
    export TF_VAR_SPRING_DATASOURCE_URL=$(gopass show --password 3/epoc/db/$1/SPRING_DATASOURCE_URL)
    # Shell does not allow dash ("-") in variable name. 
    export TF_VAR_SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI=$(gopass show --password 3/epoc/firebase/$1/SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER-URI)
    export TF_VAR_SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI=$(gopass show --password 3/epoc/firebase/$1/SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI)
    export TF_VAR_environment=$1
    echo "Secrets exported for environment: $1";
else 
    echo "Invalid envinronment: $1"
fi