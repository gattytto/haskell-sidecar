FROM haskell:8.10.1-buster

ENV HOME=/home/theia

RUN mkdir /projects ${HOME} && \
    mkdir -p ${HOME}/.stack && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
