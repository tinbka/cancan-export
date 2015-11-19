# Usage:
# include CanCan service into the $rootScope,
#   MyApp.run('MyApp', ['$rootScope', 'CanCan', ($rootScope, CanCan) ->
#     angular.extend $rootScope, CanCan
#     ...
#   ])
# then, in templates you can authorize parts like
#   can('edit', customerOrder)
# and check the permissions in a controller like
#   $scope.can('edit', $scope.customerOrder)
((global, factory) ->
    if typeof define == 'function' and define.amd?
        define ['angular', 'cancan-export'], factory
    else
        factory(global.angular, global.CanCanAbility)
)(this, (angular, CanCanAbility) ->
    angular
        .module 'cancan.export', []
        .service 'CanCan', ->
            ability: new CanCanAbility(window.gon)
            getAbility: (object) -> @ability = new CanCanAbility(object)
            can: (action, subject, argsForBlock...) -> @ability.can action, subject, argsForBlock...
            cannot: (action, subject, argsForBlock...) -> @ability.cannot action, subject, argsForBlock...
)