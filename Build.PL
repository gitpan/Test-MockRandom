use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'Test::MockRandom',
      create_makefile_pl => "passthrough",
      license         => 'perl',
	  requires        => {
	                       # module requirements here
	                     },
	  build_requires  => { 
	                       Test::Simple => 0.53,
                           Test::Exception => 0.19,
	                     },
	)->create_build_script;
