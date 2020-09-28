FROM haskell:8.10.1-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.10.2
ENV DEBIAN_KEY=427CB69AAC9D00F2A43CAF1CBA3CBA3FFE22B574
ENV CABAL_INSTALL=3.2
ENV STACK=2.3.3
ENV STACK_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
ENV STACK_RELEASE_KEY=2C6A674E85EE3FB896AFC9B965101FF31C5C154D

ENV PATH ${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin:$PATH

RUN apt update && apt install -y wget && \
    mkdir /projects ${HOME} && \
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
    rm -f *.gz && \
    git clone https://github.com/haskell/ghcide.git && cd ghcide && stack install && cd .. 
    
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
