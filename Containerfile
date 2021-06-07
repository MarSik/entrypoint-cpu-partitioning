FROM registry.access.redhat.com/ubi8/ubi

ADD entrypoint.sh /
ADD stage2.sh /
ADD process.sh /

ENTRYPOINT ["/entrypoint.sh"]
