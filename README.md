_This README is a work in progress. Some steps may be incomplete or missing_

# GroupHQ Continuous Testing Test Suite
Contains user-automated acceptance tests for either user-interface tests or API tests.
Tests are written using Ruby and the RSpec testing framework. UI tests are written using Selenium WebDriver for Ruby.

## Creating Tests
It's recommended to download the [TestWise IDE](https://agileway.com.au/testwise) for developing tests, but you can use 
any IDE of your choice.

### Prerequisites
- Ruby 3.2. [Download here](https://www.ruby-lang.org/en/downloads/)
- [Recommended] Quality assurance tools for developing tests such as [TestWise](https://agileway.com.au/testwise) or 
[JetBrains Aqua](https://www.jetbrains.com/aqua/).


### Running Tests (using TestWise)
See the [TestWise documentation](https://agileway.com.au/testwise/docs/test-execution) for information on how to run 
tests and other features.

### Adding a new test file
Currently, the continuous testing server will only run tests in the `spec` folder that are also listed
in the array returned by the `specs_for_quick_build` method in the project directory's `Rakefile`.
When adding a new test file to the spec folder, you'll need to add the test to this array 
to ensure that the tests in the new file will be run by the continuous testing server.

When you're done adding tests, commit and push the changes to the main branch. The continuous testing server will
automatically pick up the changes and run the tests on the next opened or updated pull request.

It's recommended you validate changes by running any new tests locally, and run the entire suite locally before 
submitting changes.