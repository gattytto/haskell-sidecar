FROM haskell:8.10.1-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack

RUN mkdir /projects ${HOME} && \
    mkdir -p ${HOME}/.stack && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done && \
    echo "allow-different-user: true" >> /home/theia/.stack/config.yaml && \
    stack upgrade && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-Linux-8.10.2.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-8.10.2.gz -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    rm -f *.gz
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
