Package.describe({
	name: "velocity:test-proxy",
	summary: "Dynamically created package to expose test files to mirrors",
	version: "0.0.4",
	debugOnly: true
});

Package.onUse(function (api) {
	api.use("coffeescript", ["client", "server"]);
	api.add_files("tests/jasmine/client/integration/_matchers.coffee",["client"]);
	api.add_files("tests/jasmine/client/integration/DropdownSpec.coffee",["client"]);
});