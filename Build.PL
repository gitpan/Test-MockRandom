use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'Test::MockRandom',
      create_makefile_pl => "passthrough",
      license         => 'perl',
      requires => {
          perl => 5.005,
      },
      build_requires => {
          Test::Exception => 0.19,
          Test::More => 0.54, 
      },
	)->create_build_script;
