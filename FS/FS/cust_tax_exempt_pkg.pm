package FS::cust_tax_exempt_pkg;

use strict;
use vars qw( @ISA );
use FS::Record qw( qsearch qsearchs );
use FS::cust_main_Mixin;
use FS::cust_bill_pkg;
use FS::cust_main_county;
use FS::cust_credit_bill_pkg;

@ISA = qw( FS::cust_main_Mixin FS::Record );

=head1 NAME

FS::cust_tax_exempt_pkg - Object methods for cust_tax_exempt_pkg records

=head1 SYNOPSIS

  use FS::cust_tax_exempt_pkg;

  $record = new FS::cust_tax_exempt_pkg \%hash;
  $record = new FS::cust_tax_exempt_pkg { 'column' => 'value' };

  $error = $record->insert;

  $error = $new_record->replace($old_record);

  $error = $record->delete;

  $error = $record->check;

=head1 DESCRIPTION

An FS::cust_tax_exempt_pkg object represents a record of a customer tax
exemption.  Currently this is only used for "texas tax".  FS::cust_tax_exempt
inherits from FS::Record.  The following fields are currently supported:

=over 4

=item exemptpkgnum - primary key

=item billpkgnum - invoice line item (see L<FS::cust_bill_pkg>)

=item taxnum - tax rate (see L<FS::cust_main_county>)

=item year

=item month

=item amount

=back

=head1 METHODS

=over 4

=item new HASHREF

Creates a new exemption record.  To add the examption record to the database,
see L<"insert">.

Note that this stores the hash reference, not a distinct copy of the hash it
points to.  You can ask the object for a copy with the I<hash> method.

=cut

# the new method can be inherited from FS::Record, if a table method is defined

sub table { 'cust_tax_exempt_pkg'; }

=item insert

Adds this record to the database.  If there is an error, returns the error,
otherwise returns false.

=cut

# the insert method can be inherited from FS::Record

=item delete

Delete this record from the database.

=cut

# the delete method can be inherited from FS::Record

=item replace OLD_RECORD

Replaces the OLD_RECORD with this one in the database.  If there is an error,
returns the error, otherwise returns false.

=cut

# the replace method can be inherited from FS::Record

=item check

Checks all fields to make sure this is a valid exemption record.  If there is
an error, returns the error, otherwise returns false.  Called by the insert
and replace methods.

=cut

# the check method should currently be supplied - FS::Record contains some
# data checking routines

sub check {
  my $self = shift;

  $self->ut_numbern('exemptnum')
#    || $self->ut_foreign_key('custnum', 'cust_main', 'custnum')
    || $self->ut_foreign_key('billpkgnum', 'cust_bill_pkg', 'billpkgnum')
    || $self->ut_foreign_key('taxnum', 'cust_main_county', 'taxnum')
    || $self->ut_foreign_keyn('creditbillpkgnum',
                              'cust_credit_bill_pkg',
                              'creditbillpkgnum')
    || $self->ut_number('year') #check better
    || $self->ut_number('month') #check better
    || $self->ut_money('amount')
    || $self->SUPER::check
  ;
}

=item cust_main_county

Returns the associated tax definition if it still exists in the database.
Otherwise returns false.

=cut

sub cust_main_county {
  my $self = shift;
  qsearchs( 'cust_main_county', { 'taxnum', $self->taxnum } );
}

=back

=head1 BUGS

Texas tax is still a royal pain in the ass.

=head1 SEE ALSO

L<FS::cust_main_county>, L<FS::cust_bill_pkg>, L<FS::Record>, schema.html from
the base documentation.

=cut

1;

