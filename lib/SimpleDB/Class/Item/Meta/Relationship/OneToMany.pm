package SimpleDB::Class::Item::Meta::Relationship::OneToMany;
use Moose;

extends 'SimpleDB::Class::Item::Meta::Relationship';


has 'target_class' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'target_attribute' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'mate' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'consistent' => (
    is   => 'ro',
    isa  => 'Bool',
    default => 0,
);

sub BUILD {
    my $self = shift;
    my $meta_class   = $self->meta_class;
    my $consistent   = $self->consistent;
    my $mate         = $self->mate;
    my $attribute    = $self->target_attribute;
    my $target_class = $self->target_class;
   
    $meta_class->add_method($self->method_name, sub {
        my ($self, %sub_options) = @_;
        my %search_options = (
            where => {$attribute => $self->id},
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
        if ($mate) {
            $search_options{set}{$mate} = $self;
        }

        $search_options{consistent} = $consistent;
        
        if (exists $sub_options{consistent}) {
            $search_options{consistent} = $sub_options{consistent};
        }
        return $self->simpledb->domain($target_class)->search(%search_options);
    });
}



1;
