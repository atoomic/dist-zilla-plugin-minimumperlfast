package Dist::Zilla::Plugin::MinimumPerlFast;
use strict;
use warnings;

use Moose;

use Carp 'croak';
use MooseX::Types::Perl 0.101340 qw( StrictVersionStr );
use Perl::MinimumVersion::Fast;
use List::Util qw//;

with(
	'Dist::Zilla::Role::PrereqSource' => { -version => '4.102345' },
	'Dist::Zilla::Role::FileFinderUser' => {
		-version => '4.102345',
		default_finders => [ ':InstallModules', ':ExecFiles', ':TestFiles' ]
	},
);

has version => (
	is      => 'ro',
	lazy    => 1,
	isa     => StrictVersionStr,
	builder => '_build_version',
);

has min => (
	is      => 'ro',
	lazy    => 1,
	isa     => StrictVersionStr,
	default => '5.008'
);

has max => (
	is        => 'ro',
	isa       => StrictVersionStr,
	required  => 0,
);

sub _build_version {
	my $self = shift;
	return List::Util::max($self->min, map { Perl::MinimumVersion::Fast->new(\$_->content)->minimum_version->stringify } @{ $self->found_files });
}

sub register_prereqs {
	my $self = shift;
	my $version = $self->version;
	my $max = $self->max;
	croak "Required perl version $version is higher than maximum $max" if defined $max && $version > $max;
	$self->zilla->register_prereqs({ phase => 'runtime' }, perl => $version);
	return;
}

no Moose;

1;

# ABSTRACT: Quickly detects the minimum version of Perl required for your dist

=head1 DESCRIPTION

This plugin uses L<Perl::MinimumVersion::Fast> to automatically find the minimum version of Perl required for your dist and adds it to the prereqs.

 # In your dist.ini:
 [MinimumPerl]

This plugin will search for files matching C</\.(t|pl|pm)$/i> in the C<lib/>, C<bin/>, and C<t/> directories.

=head1 SEE ALSO
Dist::Zilla

=cut

