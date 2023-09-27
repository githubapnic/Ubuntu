![](images/apnic_logo.png)
# LAB :: Simple example of Public Key Infrastructure (PKI)

* In this example we are using apnictraining.net as domain name.  
* \# super user command.  
* $  normal user command.  
* Username `apnic` and password `training`.


**Topology**

	[group1.apnictraining.net] [192.168.30.1]
	[group2.apnictraining.net] [192.168.30.2]
	......  
	[group10.apnictraining.net] [192.168.30.10]  
	[group11.apnictraining.net] [192.168.30.11]  
	......  
	[group20.apnictraining.net] [192.168.30.20]  
	[group21.apnictraining.net] [192.168.30.21]  
	......
	[group30.apnictraining.net] [192.168.30.30]  

In this lab you will generate a self-signed SSL certificate and apply it to an apache webserver.

## Lab Tasks
Step 1: Install required software<br>
Step 2: Alice and Bob create their own private and public keys.<br>
Step 3: Bob sends Alice his public key.<br>
Step 4: Alice encrypts the message using Bob’s public key and sends it to Bob.<br>
Step 5: Bob decrypts Alice’s message using his private key.<br>

### <a name="fenced-code-block">Step 1</a>
#### Install Required Software

1. Login to the server.

		ssh apnic@192.168.30.XX

	password is `training`

2. Install openssl

		sudo apt-get update
		sudo apt-get install -y openssl

	password is `training`


### <a name="fenced-code-block">Step 2</a>
#### Create Private and Public Keys
1. Make directories to store keys.

		mkdir alice bob


2. Create Alice's private key. This must be kept secret!

		cd alice
		openssl genpkey -algorithm RSA -out alice_rsa -pkeyopt rsa_keygen_bits:2048

3.  Create Alice's public key. This can be shared with other people.

		openssl rsa -in alice_rsa -pubout -out alice_rsa.pub

4. View the public key.

		cat alice_rsa.pub

5. Create Bob's private key. This must be kept secret!

		cd ../bob
		openssl genpkey -algorithm RSA -out bob_rsa -pkeyopt rsa_keygen_bits:2048

6.  Create Bob's public key. This can be shared with other people.

		openssl rsa -in bob_rsa -pubout -out bob_rsa.pub

7. Share the public key with Alice

		cp bob_rsa.pub ../alice/

### <a name="fenced-code-block">Step 3</a>
#### Share the public key
1. Share the public key with Alice

		cp bob_rsa.pub ../alice/


### <a name="fenced-code-block">Step 4</a>
#### Create an encrypted message
1. Create message from Alice

		cd ../alice
		ls -lash
		echo "secret message that will be encrypted" > message.txt
		cat message.txt

2. Encrypt the message with Bob's public key.

		openssl rsautl -encrypt -pubin -inkey bob_rsa.pub -in message.txt -out message.enc

3. Share the encrypted message with Bob.

		cp message.enc ../bob/

### <a name="fenced-code-block">Step 4</a>
#### Read an encrypted message
1. Bob decrypts the message using Bob's private key.

		cd ../bob/
		ls
		openssl rsautl -decrypt -inkey bob_rsa -in message.enc -out message.txt
		cat message.txt

***END OF EXERCISE***
