module Fixjour
  module Definitions
    # Defines the new_* method
    def define_new(builder, &block)
      define_method("new_#{builder.name}") do |*args|
        Generator.new(builder.klass, block).call(self, args.extract_options!.symbolize_keys!)
      end
    end

    # Defines the create_* method
    def define_create(builder)
      define_method("create_#{builder.name}") do |*args|
        model = send("new_#{builder.name}", *args)
        model.save!
        model
      end
    end

    # Defines the valid_*_attributes method
    def define_valid_attributes(builder)
      define_method("valid_#{builder.name}_attributes") do |*args|
        record = send("new_#{builder.name}", *args)
        valid_attributes = record.attributes
        valid_attributes.delete_if { |key, value| value.nil? }

        transfer_singular_ids = proc { |reflection|
          if associated = record.send(reflection.name)
            associated.new_record? && associated.save!
            key = reflection.options[:foreign_key] || reflection.name.to_s + '_id'
            valid_attributes[key] = associated.id
          end
        }

        record.class.reflect_on_all_associations(:has_one).each(&transfer_singular_ids)
        record.class.reflect_on_all_associations(:belongs_to).each(&transfer_singular_ids)

        transfer_plural_ids = proc { |reflection|
          if associated = record.send(reflection.name)
            associated.each { |rec| rec.new_record? && rec.save! }
            key = reflection.options[:foreign_key] || reflection.name.to_s + '_id'
            valid_attributes[key.to_s + 's'] = associated.map(&:id)
            valid_attributes.delete(reflection.name)
          end
        }

        record.class.reflect_on_all_associations(:has_many).each(&transfer_plural_ids)

        valid_attributes.stringify_keys!
        valid_attributes.make_indifferent!
        valid_attributes
      end
    end
  end
end
