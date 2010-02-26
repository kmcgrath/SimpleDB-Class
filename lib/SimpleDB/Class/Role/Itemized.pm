package SimpleDB::Class::Role::Itemized;

use Moose::Role;
use SimpleDB::Class::Types ':all';

requires 'item_class';

=head1 NAME

SimpleDB::Class::Role::Itemized - Provides utility methods to classes that need to instantiate items.

=head1 SYNOPSIS

 my $class = $self->determine_item_class(\%attributes);

 my $item = $self->instantiate_item(\%attributes, $id);

 my $item = $self->parse_item($id, \@attributes);

=head1 DESCRIPTION

This is a L<Moose::Role> that provides utility methods for instantiating L<SimpleDB::Class::Item>s.

=head1 METHODS

The following methods are available from this role.

=cut

#--------------------------------------------------------

=head2 instantiate_item ( attributes, [ id ] )

Instantiates an item based upon it's proper classname and then calls C<update> to populate it's attributes with data.

=head3 attributes

A hash reference of attribute data.

=head3 id

An optional id to instantiate the item with.

=cut

sub instantiate_item {
    my ($self, $attributes, $id) = @_;
    my %params = (simpledb=>$self->simpledb);
    if (defined $id && $id ne '') {
        $params{id} = $id;
    }
    return $self->determine_item_class($attributes)->new(%params)->update($attributes);
}

#--------------------------------------------------------

=head2 determine_item_class ( attributes ) 

Given an attribute list we can determine if an item needs to be recast as a different class.

=head3 attributes

A hash ref of attributes.

=cut

sub determine_item_class {
    my ($self, $attributes) = @_;
    my $class = $self->item_class;
    my $castor = $class->_castor_attribute;
    if ($castor) {
        my $reclass = $attributes->{$castor};
        if ($reclass) {
            return $reclass;
        }
    }
    return $class;
}

#--------------------------------------------------------

=head2 parse_item ( id , attributes ) 

Converts the attributes section of an item document returned from SimpleDB into a L<SimpleDB::Class::Item> object.

=head3 id

The ItemName of the item to create.

=head3 attributes

An array of attributes as returned by L<SimpleDB::Class::HTTP>.

=cut

sub parse_item {
    my ($self, $id, $list) = @_;
    unless (ref $list eq 'ARRAY') {
        $list = [$list];
    }

    # format the data into a reasonable structure
    my $attributes = {};
    foreach my $attribute (@{$list}) {

        # get attribute name
        unless (exists $attribute->{Name}) {
            return undef; # empty result set
        }
        my $name = $attribute->{Name};

        # skip handling the 'id' field
        next if $name eq 'id';

        # get value
        my $value = $attribute->{Value};

        # create expected hashref
        if (exists $attributes->{$name}) {
            if (ref $attributes->{$name} ne 'ARRAY') {
                $attributes->{$name} = [$attributes->{$name}];
            }
            push @{$attributes->{$name}}, $value;
        }
        else {
            $attributes->{$name} = $value;
        }
    }

    # now we can determine the item's class from attributes if necessary
    my $item_class = $self->determine_item_class($attributes);

    # and appropriately format it's attribute values
    foreach my $name (keys %{$attributes}) {
        if (ref $attributes->{$name} eq 'ARRAY') {
            my $i = 0;
            foreach my $value (@{$attributes->{$name}}) {
                $attributes->{$name}[$i] = $item_class->parse_value($name, $value);
                $i++;
            }
        }
        else {
            $attributes->{$name} = $item_class->parse_value($name, $attributes->{$name});
        }
    }

    # now we're ready to instantiate
    return $item_class->new(simpledb=>$self->simpledb, id=>$id)->update($attributes);
}

=head1 LEGAL

SimpleDB::Class is Copyright 2009-2010 Plain Black Corporation (L<http://www.plainblack.com/>) and is licensed under the same terms as Perl itself.

=cut


1;
