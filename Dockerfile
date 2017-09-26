FROM alpine:latest

ENV FILE_LIST "brave chrome_100_percent.pak chrome_200_percent.pak electron_resources.pak icudtl.dat locales natives_blob.bin resources snapshot_blob.bin"
# Add these at runtime
# ENV AWS_ACCESS_KEY_ID
# ENV AWS_SECRET_ACCESS_KEY

RUN apk add --update openssl
RUN wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN apk --no-cache add p7zip groff less python
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm awscli-bundle.zip
RUN rm -rf awscli-bundle
WORKDIR /opt

ADD upload.py /opt/upload.py
RUN chmod +x /opt/upload.py

ENTRYPOINT ["python", "/opt/upload.py"]
# CMD "s3://brave-test-builds/target.zip"

VOLUME /opt/target
WORKDIR /opt/target

