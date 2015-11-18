# Cancan::Export

It is the rewrite of a vital parts of CanCan v.1.13.1 classes: Ability and Rule.  
All method names writen in a snake case is rewrites of the CanCan ones.

This rewrite is simplified since we don't have ORM objects and real DB relations.  
All we have on the client-side is plain old objects,   
though as long as each object has `_type' or `type' property, it can be identified as an object of a specific model.

## Usage

```javascript
ability = new CanCanAbility(gon)
ability.can('read', 'CustomerOrder')
// => true or false
customerOrder = {partner_id: 123} 
// or with restmod
customerOrder = CustomerOrder.$build({ partner_id: 123 });
ability.can('edit', customerOrder)
// => true, if a partner can edit only his orders and gon.user.partner_id == 123
```

### With angular

```javascript
// include CanCan service into the $rootScope,
  MyApp.run(['$rootScope', 'CanCan', function($rootScope, CanCan) {
    angular.extend $rootScope, CanCan
    ...
  ])
// then, in templates you can authorize parts like
  can('edit', customerOrder)
// and check the permissions in a controller like
  $scope.can('edit', $scope.customerOrder)
```