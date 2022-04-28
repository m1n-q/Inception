FROM debian:buster

RUN if [ -z "${FOO}" ]; then \
		echo "failed to load \$FOO" > /fail; \
	else \
		echo $FOO; \
	fi

COPY test.sh /
ENTRYPOINT ["bash", "/test.sh"]
