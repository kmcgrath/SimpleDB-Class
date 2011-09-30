package SimpleDB::Class::Item::Meta;
use Moose::Role;

has 'relationships' => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef[SimpleDB::Class::Item::Meta::Relationship]',
    writer  => '_set_relationships',
    handles => {
          _set_relationship   => 'set',
          get_relationship   => 'get',
          has_relationship   => 'exists',
      },
); 


has 'relationship_class_map' => (
    traits => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef[Str]',
    handles => {
          set_relationship_class  => 'set',
          get_relationship_class  => 'get',
      },

    default => sub {
        {
          'one to many' => 'SimpleDB::Class::Item::Meta::Relationship::OneToMany',
        }
    },

);



*set_relationships = \&set_relationship;
sub set_relationship {
    my $self = shift;

    my %args = @_;

    foreach my $rel (keys %args) {
        my $class = $self->get_relationship_class($rel);
        #my %map;
        if ($class) {
            Class::MOP::load_class($class);
            my $rel_obj = $class->new(meta_class=>$self, %{$args{$rel}});
            if ($rel_obj) {
                #$map{$rel_obj->method_name} = $rel_obj;
                $self->_set_relationship($rel_obj->method_name => $rel_obj);
            }
            #$self->_set_relationships(\%map); 
        }
    }

};


1;
