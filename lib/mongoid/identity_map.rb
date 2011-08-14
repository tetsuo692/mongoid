# encoding: utf-8
module Mongoid #:nodoc:

  # Defines behaviour for the identity map in Mongoid.
  class IdentityMap < Hash

    # Get a document from the identity map by its id.
    #
    # @example Get the document from the map.
    #   map.get(Person, id)
    #
    # @param [ Class ] klass The class of the document.
    # @param [ Object ] id The document id.
    #
    # @return [ Document ] The matching document.
    #
    # @since 2.1.0
    def get(klass, id)
      return nil unless Mongoid.identity_map_enabled?
      documents_for(klass)[id]
    end

    # Get a single document that matches the provided criteria.
    #
    # @example Get the document for the criteria.
    #   map.match(Person.where(:_id => id))
    #
    # @param [ Criteria ] criteria The criteria to match.
    #
    # @return [ Document ] The first matching document.
    #
    # @since 2.1.0
    def match(criteria)
      return nil unless Mongoid.identity_map_enabled?
      documents_for(criteria.klass).values.detect do |doc|
        doc.matches?(criteria.selector)
      end
    end

    # Remove the document from the identity map.
    #
    # @example Remove the document.
    #   map.removed(person)
    #
    # @param [ Document ] document The document to remove.
    #
    # @return [ Document, nil ] The removed document.
    #
    # @since 2.1.0
    def remove(document)
      return nil unless Mongoid.identity_map_enabled? && document && document.id
      documents_for(document.class).delete(document.id)
    end

    # Puts a document in the identity map, accessed by it's id.
    #
    # @example Put the document in the map.
    #   identity_map.set(document)
    #
    # @param [ Document ] document The document to place in the map.
    #
    # @return [ Document ] The provided document.
    #
    # @since 2.1.0
    def set(document)
      return nil unless Mongoid.identity_map_enabled? && document && document.id
      documents_for(document.class)[document.id] = document
    end

    private

    # Get the documents in the identity map for a specific class.
    #
    # @example Get the documents for the class.
    #   map.documents_for(Person)
    #
    # @param [ Class ] klass The class to retrieve.
    #
    # @return [ Hash ] The documents.
    #
    # @since 2.1.0
    def documents_for(klass)
      self[klass] ||= {}
    end

    class << self

      # For ease of access we provide the same API to the identity map on the
      # class level, which in turn just gets the identity map that is on the
      # current thread.
      #
      # @example Get a document from the current identity map by id.
      #   IdentityMap.get(id)
      #
      # @example Set a document in the current identity map.
      #   IdentityMap.set(document)
      #
      # @since 2.1.0
      delegate *(
        Hash.public_instance_methods(false) +
        IdentityMap.public_instance_methods(false) <<
        { :to => :"Mongoid::Threaded.identity_map" }
      )
    end
  end
end
