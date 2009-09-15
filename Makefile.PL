use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Rad::Plugin::MatrizPrinter',
    AUTHOR              => q{Fernando Correa de Oliveira <fco@cpan.org>},
    VERSION_FROM        => 'lib/App/Rad/Plugin/MatrizPrinter.pm',
    ABSTRACT_FROM       => 'lib/App/Rad/Plugin/MatrizPrinter.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-Rad-Plugin-MatrizPrinter-*' },
);
