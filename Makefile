.PHONY: aws-plan aws-destroy aws-rebuild

aws-plan:
	terraform -chdir=environments/aws/lab plan

aws-destroy:
	bash scripts/aws-lab-destroy.sh

aws-rebuild:
	bash scripts/aws-lab-rebuild.sh
