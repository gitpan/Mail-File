use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		        => 'Mail::File',
    'VERSION_FROM'	    => 'lib/Mail/File.pm',
    'PREREQ_PM'		    => {
		'File::Temp'        => 0,
		'File::Path'        => 0,
		'File::Basename'    => 0,
		'Time::Piece'       => 0,
		'Test::More'        => 0.47,
	},
	NO_META			=> 1,

    ($] >= 5.005 ?
      (ABSTRACT_FROM    => 'lib/Mail/File.pm',
       AUTHOR           => 'Barbie <barbie@cpan.org>') : ()),
);
