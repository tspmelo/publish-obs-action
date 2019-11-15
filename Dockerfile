FROM opensuse/tumbleweed

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install osc tar git

COPY entrypoint.sh /entrypoint.sh
COPY checkin.sh /checkin.sh
COPY changelog.sh /changelog.sh

ENTRYPOINT ["/entrypoint.sh"]