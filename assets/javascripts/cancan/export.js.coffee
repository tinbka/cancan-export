# It is the rewrite of a vital parts of CanCan v.1.13.1 classes: Ability and Rule.
# All method names writen in a snake case is rewrites of the CanCan ones.
#
# This rewrite is simplified since we don't have ORM objects and real DB relations.
# All we have on the client-side is plain old objects, 
# though as long as each object has `_type' or `type' property, it can be identified as an object of a specific model.
#
# Usage:
#   ability = new CanCanAbility(gon)
#   ability.can('read', 'CustomerOrder')
#   # => true or false
#   customerOrder = {partner_id: 123} 
#   # or with restmod
#   customerOrder = CustomerOrder.$build({ partner_id: 123 });
#   ability.can('edit', customerOrder)
#   # => true, if a partner can edit only his orders and gon.user.partner_id == 123
((global, factory) ->
    if typeof define == 'function' and define.amd?
        define ['lodash'], factory
    else
        factory(global._)
)(this, (_) ->
  class @CanCanAbility
    rules: []
    rulesIndex: {}
    helpers: [] 
      
    # @ data : [gon Object]
    constructor: (data) ->
        @user = data.user
        $.extend @, data.ability
      
        # Import each helper defined in ruby's Ability object.
        # `this' must be the object in which context `user' property is defined, thus it is Ability itself
        for name, source in @helpersSource
            @[name] = $.proxy eval(source), @
      
        @rules = @rules.map (data) =>
            new Rule(data, @)
        
    can: (action, subject, extra_args...) ->
        relevant_rules = @relevant_rules(action, subject)
      
        match = _(relevant_rules).find (rule) =>
            rule.matches_conditions(action, subject, extra_args)
        
        match and match.baseBehavior or false
    
    cannot: (action, object, extra_args...) ->
        !@can action, object, extra_args...
      
      
    typeOf: (subject) ->
        if typeof subject == 'string'
            subject
        else
            subject._type or subject.type
        
    matches_subject: (subjects, subject) ->
        _(subjects).include('all') or # wildcard rule
        _(subjects).include(@typeOf subject)
          
    relevant_rules: (action, subject) ->
        _.clone(@rules).reverse().filter (rule) =>
            @matches_subject(rule.subjects, subject) and rule.is_relevant action, subject
      
    
    class Rule
        # there are nor subjects nor actions
        matchAll: false
        # can or cannot?
        baseBehavior: true
        # what to do?
        actions: []
        # object model names
        # N.B. a Class starts with a Capital letter; a plain string/symbol with a small letter
        subjects: []
        # `where' hash on a model
        conditions: {}
        # function to check against
        block: null
      
        constructor: (data, ability) ->
            $.extend @, data
            @ability = ability
            @block = $.proxy eval(data.blockSource), ability
        
        typeOf: CanCanAbility.prototype.typeOf
        
        is_relevant: (action, subject) ->
            @matchAll or (@matches_action(action) and @matches_subject(subject))
          
        matches_action: (action) ->
            _(@actions).include('manage') or # wildcard rule
            _(@actions).include(action)
      
        matches_subject: (subject) ->
            @ability.matches_subject(@subjects, subject)
      
        # Nested subjects matching is not supported now
        matches_conditions: (action, subject, extra_args) ->
            if @matchAll
                @call_block_with_all(action, subject, extra_args)
            else if @block && typeof subject != 'string'
                @block(subject, extra_args...)
            else if @conditions && typeof subject != 'string'
                @matches_conditions_hash(subject)
            else
                # Don't stop at "cannot" definitions when there are conditions.
                # We want, if @baseBehavior is false, Ability#relevant_rules to not accept the result and check the next rule.
                !@conditions or $.isEmptyObject(@conditions) or @baseBehavior
      
        # This is not suported yet. Use of this hook implies that we're able to pass a _class_ into block function,
        # but for the while we can't
        call_block_with_all: (action, subject, extra_args) ->
            if typeof subject == 'string'
                @block(action, subject, nil, extra_args...)
            else
                @block(action, @typeOf(subject), subject, extra_args...)
          
        # @ subject : [resource Object] : a pattern we match against
        # @ conditions : [Object] : a pattern we match against
        matches_conditions_hash: (subject, conditions=@conditions) ->
            return true if $.isEmptyObject conditions
            every_match = not _(conditions).find (value, name) =>
                !@condition_match(subject[name], value)
            
        # @ attribute : a value which we match
        # @ value : a pattern we match against
        condition_match: (attribute, value) ->
            if $.isPlainObject value
                @hash_condition_match(attribute, value)
            else if $.isArray value
                # match against any of the rule condition values will do
                _(value).include(attribute)
            else
                # only exact equality will do
                attribute == value
      
        # @ attribute : a value which we match
        # @ value : [Object] : a pattern we match against
        hash_condition_match: (attribute, value) ->
            if $.isArray attribute
                # match of any element of [Array] attribute against the rule condition hash will do (recursion)
                _(attribute).find (element) => @matches_conditions_hash(element, value)
            else
                attribute? && @matches_conditions_hash?(attribute, value)
)