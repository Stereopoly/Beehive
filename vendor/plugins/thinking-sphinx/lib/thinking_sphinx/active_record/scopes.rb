module ThinkingSphinx
  module ActiveRecord
    module Scopes
      def self.included(base)
        base.class_eval do
          extend ThinkingSphinx::ActiveRecord::Scopes::ClassMethods
        end
      end
    
      module ClassMethods
        
        ***REMOVED*** Similar to ActiveRecord's default_scope method Thinking Sphinx supports
        ***REMOVED*** a default_sphinx_scope. For example:
        ***REMOVED***
        ***REMOVED***    default_sphinx_scope :some_sphinx_named_scope
        ***REMOVED***
        ***REMOVED*** The scope is automatically applied when the search method is called. It
        ***REMOVED*** will only be applied if it is an existing sphinx_scope.
        def default_sphinx_scope(sphinx_scope_name)
          @default_sphinx_scope = sphinx_scope_name
        end

        ***REMOVED*** Returns the default_sphinx_scope or nil if none is set.
        def get_default_sphinx_scope
          @default_sphinx_scope
        end

        ***REMOVED*** Returns true if the current Model has a default_sphinx_scope. Also checks if
        ***REMOVED*** the default_sphinx_scope actually is a scope.
        def has_default_sphinx_scope?
          !@default_sphinx_scope.nil? && sphinx_scopes.include?(@default_sphinx_scope)
        end

        ***REMOVED*** Similar to ActiveRecord's named_scope method Thinking Sphinx supports
        ***REMOVED*** scopes. For example:
        ***REMOVED***
        ***REMOVED***   sphinx_scope(:latest_first) { 
        ***REMOVED***       {:order => 'created_at DESC, @relevance DESC'}
        ***REMOVED***     }
        ***REMOVED***
        ***REMOVED*** Usage:
        ***REMOVED***
        ***REMOVED***   @articles =  Article.latest_first.search 'pancakes'
        ***REMOVED***
        def sphinx_scope(method, &block)
          @sphinx_scopes ||= []
          @sphinx_scopes << method
          
          singleton_class.instance_eval do
            define_method(method) do |*args|
              options = {:classes => classes_option}
              options.merge! block.call(*args)
              
              ThinkingSphinx::Search.new(options)
            end
            
            define_method("***REMOVED***{method}_without_default".to_sym) do |*args|
              options = {:classes => classes_option, :ignore_default => true}
              options.merge! block.call(*args)
              
              ThinkingSphinx::Search.new(options)
            end
          end
        end

        ***REMOVED*** This returns an Array of all defined scopes. The default
        ***REMOVED*** scope shows as :default.
        def sphinx_scopes
          @sphinx_scopes || []
        end
        
        def remove_sphinx_scopes
          sphinx_scopes.each do |scope|
            singleton_class.send(:undef_method, scope)
          end
          
          sphinx_scopes.clear
        end
      end
    end
  end
end