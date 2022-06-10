build:
	dart run build_runner build --delete-conflicting-outputs

# https://dart.dev/tools/dart-tool
create_cli:
	dart create -t console my_app

# https://dart.dev/tools/dart-compile
# The dart compile command replaces the dart2native, dart2aot, and dart2js commands.
compile_window:
	dart compile exe bin/integration_spec.dart -o bin/integration_spec.exe

compile_mac:
	dart compile exe bin/integration_spec.dart -o bin/integration_spec

run:
	time bin/integration_spec