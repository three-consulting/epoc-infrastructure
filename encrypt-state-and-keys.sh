for filename in $( find . -name "epoc-terraform-sa-*.json" ); do \
  gpg --batch --yes --symmetric --passphrase $(gopass show 3/epoc/GPG) --cipher-algo AES-256 $filename; \
done

for filename in $( find . -name "terraform.tfstate" ); do \
  gpg --batch --yes --symmetric --passphrase $(gopass show 3/epoc/GPG) --cipher-algo AES-256 $filename; \
done