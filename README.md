# Cold501 - a Ruby on Rails website for HEAT @ TAMU using pgSQL 
## Caden Miller, Erik Achtermann, James Guandolo, Shanti Patel

### Specs

- Rails Version
	- 3.1.2
- Gems versions and version changes listed in following files
	- ```console
		gem_versions.md
		gem_version_changes.md
	  ```

### Setup

1. Clone GitHub repo in your projects folder (called csce431 from here on out)
	- ssh
		- ```console
			git clone git@github.com:caden-miller/cold501.git
		  ```
	- https
		- ```console
			git clone https://github.com/caden-miller/cold501.git
		  ```

2. Run docker command at csce431/ 
	- ```console
		sudo docker run -it --volume "$(pwd):/csce431" -e DATABASE_USER=cold_app -e DATABASE_PASSWORD=cold_password -p 3000:3000 paulinewade/csce431:latest
	  ```

3. Go into the project directory within Docker
	- ```console
		cd csce431/cold501/
	  ```

4. Install all rails gems
	- ```console
		bundle install
	  ```

5. Setup the rails database
	- ```console
		rails db:create
	  ```
	- ```console
		rails db:migrate
	  ```
	- once seeding is implemented 
		- ```console
			rails db:seed
		  ```

6. Run the server locally
	- ```console
		rails s --binding=0.0.0.0
	  ```

7. Navigate to the rails server in your browser
	- https://127.0.0.1/

### How to Setup Environment Variables
1. Create a .env file in the cold501/ directory
	- ```console
		touch .env
	  ```
2. Modify the .env file to include the following credentials
	- ```bash
		# Google OAuth credentials and redirect URL
		GOOGLE_OAUTH_CLIENT_ID=<INSERT HERE>
		GOOGLE_OAUTH_CLIENT_SECRET=<INSERT HERE>
		HOST_URL=<http://localhost:3000 or siteURL if hosting elsewhere>

		# PostgreSQL Database credentials
		DATABASE_PASSWORD=<INSERT HERE>
		DATABASE_USER=<INSERT HERE>
		
		# Cloudflare R2 photo hosting (S3-compatible).
		# Leave R2_BUCKET blank for local development - uploads then go to
		# public/uploads/ on disk instead of R2.
		R2_ACCESS_KEY_ID=<INSERT HERE>
		R2_SECRET_ACCESS_KEY=<INSERT HERE>
		R2_BUCKET=<R2 bucket name>
		R2_ENDPOINT=https://<CLOUDFLARE_ACCOUNT_ID>.r2.cloudflarestorage.com
		R2_PUBLIC_URL=https://<public r2.dev URL or custom domain>
	  ```

### How to Contribute

1. Open another Ubuntu terminal at csce431/cold501/ (outside of docker instance)
	- this is where you commit things

2. We want to commit to a feature branch and follow TDD
	- check branch
		- ```console
			git branch
		  ```
	- switch branch
		- ```console
			git switch <branch>
		  ```
	- create an upstream reference to a new feature branch
		- ```console
			git checkout -b <feature_branch>
		  ```
	- only commit to a feature branch
	- make tests for your feature first in the spec/ directory
		- happy unit tests
		- sad unit tests
		- integration tests
	- once you're done working for the moment or want to commit your history
		- ```console
			git add .
		  ```
		- ```console
			git commit -m "<explain what you did>"
		  ```
		- ```console
			git push origin <feature_branch>
		  ```

3. Merge your changes and verify tests pass
	- create a pull request from <feature_branch> to dev on GitHub GUI
	- create a pull request from dev to test
		- ensure all tests pass
	- create a pull request from test to main
		- ensure the tests pass and the test branch is working locally