echo "Make sure to add your AWS credentials into .env"
docker build -t ansible-terraform . && docker run -it --env-file .env -v $(pwd):/palm-node ansible-terraform
