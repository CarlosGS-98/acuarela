use 5.042000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Acuarela',
    VERSION_FROM      => 'lib/Acuarela.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {'Converter::Color' => 0.18}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Acuarela.pm', # retrieve abstract from module
    AUTHOR            => 'CarlosGS-98 <cgonzalezsanz98@gmail.com>',
    LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #https://metacpan.org/pod/Module::Build::API
);
