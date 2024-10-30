.PHONY: all publish server

all:

publish:
	./bin/publish.sh --force

server:
	# runs a server on localhost for testing
	#hugo-extended server -D
	/usr/bin/hugo server -D
