init:
	mkdir -p data/srv-sfpgo
	mkdir -p data/var-lib-sftpgo
	mkdir -p data/srv-sfpgo/backups
	mkdir -p data/srv-sfpgo/data
	mkdir -p data/srv-sfpgo/data/ftpuploader

up: init
	docker-compose up

reset:
	rm -rf data/var-lib-sftpgo/*
	docker-compose down -v
	docker volume rm aws-legacy-s3-ftp_srv-sftpgo || true
	docker volume rm aws-legacy-s3-ftp_var-lib-sftpgo || true
	docker volume rm aws-legacy-s3-ftp_etc-sftpgo-init || true
