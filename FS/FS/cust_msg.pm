package FS::cust_msg;

use strict;
use base qw( FS::cust_main_Mixin FS::Record );
use FS::Record qw( qsearch qsearchs );
use MIME::Parser;
use vars qw( @statuses );

=head1 NAME

FS::cust_msg - Object methods for cust_msg records

=head1 SYNOPSIS

  use FS::cust_msg;

  $record = new FS::cust_msg \%hash;
  $record = new FS::cust_msg { 'column' => 'value' };

  $error = $record->insert;

  $error = $record->check;

=head1 DESCRIPTION

An FS::cust_msg object represents an email message generated by Freeside 
and sent to a customer (see L<FS::msg_template>).  FS::cust_msg inherits 
from FS::Record.  The following fields are currently supported:

=over 4

=item custmsgnum - primary key

=item custnum - customer number

=item msgnum - template number

=item msgtype - the message type

=item _date - the time the message was sent

=item env_from - envelope From address

=item env_to - envelope To addresses, including Bcc, separated by newlines

=item header - message header

=item body - message body

=item error - Email::Sender error message (or null for success)

=back

=head1 METHODS

=over 4

=item new HASHREF

Creates a new 

=cut

# the new method can be inherited from FS::Record, if a table method is defined

sub table { 'cust_msg'; }

sub nohistory_fields { ('header', 'body'); } 
# history is kind of pointless on this table

@statuses = qw( prepared sent failed );

=item insert

Adds this record to the database.  If there is an error, returns the error 
and emits a warning; otherwise returns false.

=cut

sub insert {
  # warn of all errors here; failing to insert/update one of these should 
  # cause a warning at worst
  my $self = shift;
  my $error = $self->SUPER::insert;
  warn "[cust_msg] error logging message status: $error\n" if $error;
  return $error;
}

=item delete

Delete this record from the database.  There's no reason to do this.

=cut

sub delete {
  my $self = shift;
  warn "[cust_msg] log entry deleted\n";
  return $self->SUPER::delete;
}

=item replace OLD_RECORD

Replaces the OLD_RECORD with this one in the database.  If there is an error,
returns the error and emits a warning, otherwise returns false.

=cut

sub replace {
  my $self = shift;
  my $error = $self->SUPER::replace(@_);
  warn "[cust_msg] error logging message status: $error\n" if $error;
  return $error;
}

=item check

Checks all fields to make sure this is a valid example.  If there is
an error, returns the error, otherwise returns false.  Called by the insert
and replace methods.

=cut

# the check method should currently be supplied - FS::Record contains some
# data checking routines

sub check {
  my $self = shift;

  my $error = 
    $self->ut_numbern('custmsgnum')
    || $self->ut_numbern('custnum')
    || $self->ut_foreign_keyn('custnum', 'cust_main', 'custnum')
    || $self->ut_numbern('msgnum')
    || $self->ut_foreign_keyn('msgnum', 'msg_template', 'msgnum')
    || $self->ut_numbern('_date')
    || $self->ut_textn('env_from')
    || $self->ut_textn('env_to')
    || $self->ut_anything('header')
    || $self->ut_anything('body')
    || $self->ut_enum('status', \@statuses)
    || $self->ut_textn('error')
    || $self->ut_enum('msgtype', [  '',
                                    'invoice',
                                    'receipt',
                                    'admin',
                                    'report',
                                 ])
  ;
  return $error if $error;

  $self->SUPER::check;
}

=item entity

Returns the complete message as a L<MIME::Entity>.

=item parts

Returns a list of the MIME parts contained in the message, as L<MIME::Entity>
objects.

=cut

sub entity {
  my $self = shift;
  if ( !exists($self->{entity}) ) {
    my $parser = MIME::Parser->new;
    my $output_dir = "$FS::UID::cache_dir/cache.$FS::UID::datasrc/mimeparts";
    mkdir($output_dir) unless -d $output_dir;
    $parser->output_under($output_dir);
    $self->{entity} =
      $parser->parse_data( $self->header . "\n" . $self->body );
  }
  $self->{entity};
}

sub parts {
  my $self = shift;
  # return only the parts with bodies, not the multipart containers
  grep { $_->bodyhandle } $self->entity->parts_DFS;
}

=back

=head1 SEE ALSO

L<FS::msg_template>, L<FS::cust_main>, L<FS::Record>.

=cut

1;

