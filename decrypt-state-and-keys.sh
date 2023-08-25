for filename in $( find . -name "*.gpg" ); do \
  gpg -q --batch --yes --decrypt-files --passphrase=$(gopass show 3/epoc/GPG) $filename; \
done