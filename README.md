# CSSE-490-lab-5

Lab 5: Security, Authentication, Authorization, and a SPA day for our TODO App

## Project Setup


### Cloning and Installing Dependencies

Make sure you have Ruby 3.1.4 or Ruby 3.2.x installed locally [on Windows using WSL](https://gorails.com/setup/windows/11) or [on Mac/Linux](https://www.ruby-lang.org/en/documentation/installation/). To push to Heroku, you'll also need to install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)).  If using Ruby 3.2.x, update the `.ruby-version` file to match your version of Ruby.

You will also need postgresql installed.  On OS X you can install it via `brew install postgresql`.  On Linux/WSL use the instructions in [Get started with databases on Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database).  Be sure to *start* the postgres database server once you have installed postgres itself (instructions are printed out via. brew/in the article).  On Linux/WSL you will likely need to run `apt install libpq-dev` in order to install all of the python packages below.

You will also need [Node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

To push to Heroku, you'll also need to install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)).

```sh
$ git clone <repo url>
$ cd lab-6-<your_github_username>
# NOTE: Bundle will fail if you haven't installed postgres yet
$ bundle
$ npm install
```

Prepare the database:
```
$ cp config/database.yml.example config/database.yml
# Update config/database.yml with any username or password information required for your local postgres server
$ rake db:create
$ rake db:migrate
$ rake db:environment:set
$ rake db:test:prepare
```

### Running Tests

Run the full test suite with `rake` or `rake test`.

Run a single test with `rspec spec/path/to_spec.rb:6`, replacing `rspec/path/to_spec.rb` with the path to your actual test, and `6` with the actual line number of the test you are trying to run.

If you want to run all the tests in a file, stopping at the first failure: `rspec --fail-fast spec/path/to_spec.rb`

#### React Tests

**Note**: In this demo application, I haven't included any React tests.  I'm including this section in the README for your reference as you develop your own applications in the future.

Run the react test suite with `npm test`

This launches the test runner in the interactive watch mode. See [running tests](https://facebook.github.io/create-react-app/docs/running-tests) in the create-react-app documentation for more information.

### Running Locally

**The Sinatra App**

```sh
$ rerun rackup
```

* `rerun` watches for filesystem changes and restarts your app as needed
* `rackup` runs rack applications (Sinatra is a rack application)

Your app should now be running on [localhost:9292](http://localhost:9292/).

**The React App**

You will run the react app in a different terminal tab than the one that you are using to run flask.

`npm start`

Runs the app in the development mode. While it is available at lvh.me:3000, you __will not__ be accessing it that way.  Instead, you will access it from within the Flask app.

The page will reload if you make edits.  You will also see any lint errors in the console.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

## Deploying to Heroku

### Creating the Heroku application


#### ** DO NOT DEPLOY YET **

```sh
$ heroku create

$ heroku buildpacks:add --index 1 heroku/ruby
$ heroku buildpacks:add --index 2 heroku/nodejs

# Create the postgres database
$ heroku addons:create heroku-postgresql:mini

$ git push heroku main
$ heroku run rake db:migrate

$ heroku open
```

### Testing in a local Heroku environment

```sh
$ heroku local
```

### Pushing up new updates to the existing application

```sh
$ git push heroku main
```
