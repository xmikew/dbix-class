package DBIx::Class::Storage::DBI::SQLite;

use strict;
use warnings;
use POSIX 'strftime';
use File::Copy;
use Path::Class;

use base qw/DBIx::Class::Storage::DBI::MultiDistinctEmulation/;

sub last_insert_id {
  return $_[0]->dbh->func('last_insert_rowid');
}

sub backup
{
  my ($self) = @_;

  ## Where is the db file?
  my $dsn = $self->connect_info()->[0];

  my $dbname = $1 if($dsn =~ /dbname=([^;]+)/);
  if(!$dbname)
  {
    $dbname = $1 if($dsn =~ /^dbi:SQLite:(.+)$/i);
  }
  $self->throw_exception("Cannot determine name of SQLite db file") 
    if(!$dbname || !-f $dbname);

  print "Found database: $dbname\n";
  my $dbfile = file($dbname);
#  my ($vol, $dir, $file) = File::Spec->splitpath($dbname);
  my $file = $dbfile->basename();
  $file = strftime("%y%m%d%h%M%s", localtime()) . $file; 
  $file = "B$file" while(-f $file);
  
  my $res = copy($dbname, $file);
  $self->throw_exception("Backup failed! ($!)") if(!$res);

  return $file;
}

1;

=head1 NAME

DBIx::Class::PK::Auto::SQLite - Automatic primary key class for SQLite

=head1 SYNOPSIS

  # In your table classes
  __PACKAGE__->load_components(qw/PK::Auto Core/);
  __PACKAGE__->set_primary_key('id');

=head1 DESCRIPTION

This class implements autoincrements for SQLite.

=head1 AUTHORS

Matt S. Trout <mst@shadowcatsystems.co.uk>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
