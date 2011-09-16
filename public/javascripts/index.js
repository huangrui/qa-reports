/* DO NOT MODIFY. This file was compiled Thu, 15 Sep 2011 18:40:50 GMT from
 * /Users/pyykkis/work/qa-reports/app/coffeescripts/index.coffee
 */

var directives;
directives = {
  profiles: {
    'name@href': function() {
      return this.url;
    },
    testsets: {
      'name@href': function() {
        return this.url;
      },
      products: {
        'name@href': function() {
          return this.url;
        }
      }
    }
  }
};
$('#report_navigation').render(index_model, directives);