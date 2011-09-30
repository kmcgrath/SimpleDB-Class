package SimpleDB::Class::Item::Meta::Relationship::OneToMany;
use Moose;

extends 'SimpleDB::Class::Item::Meta::Relationship';


has 'class_name' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'attribute' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'options' => (
    is   => 'ro',
    isa  => 'Hash',
);


sub BUILD {
    my $self = shift;
    my $meta_class = $self->meta_class;
   
    $meta_class->add_method($self->method_name, sub {
        my ($self, %sub_options) = @_;
        my %search_options = (
            where => {$self->attribute => $self->id},
        );
        if (exists $sub_options{where}) {
            $search_options{where}{'-and'} = $sub_options{where};
        }
        if ($sub_options{order_by}) {
            $search_options{order_by} = $sub_options{order_by};
        }
        if ($sub_options{limit}) {
            $search_options{limit} = $sub_options{limit};
        }
        if (exists $sub_options{set}) {
            $search_options{set} = $sub_options{set};
        }
        if ($self->options->{mate}) {
            $search_options{set}{$self->options->{mate}} = $self;
        }
        if (exists $self->options->{consistent}) {
            $search_options{consistent} = $self->options->{consistent};
        }
        if (exists $sub_options{consistent}) {
            $search_options{consistent} = $sub_options{consistent};
        }
        return $self->simpledb->domain($self->class_name)->search(%search_options);
    });
}



1;
