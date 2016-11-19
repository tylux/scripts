# RabbitMQ Checks
###### Designed for Nagios type monitoring systems.



# Compile for both macOS and Linux systems with
```
make build
```
Currently checks for RabbitMQ Aliveness, If everything is working correctly, will return HTTP status 200


```
./rabbitmq --help
Usage of ./rabbitmq-mac:
  -H string
    	-H RabbitMQ Host (default "localhost")
  -P string
    	-P RabbitMQ Port (default "15672")
  -p string
    	-p RabbitMQ Password (default "guest")
  -u string
    	-u RabbitMQ Username (default "guest")
```
