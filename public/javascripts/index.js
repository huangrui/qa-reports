/* DO NOT MODIFY. This file was compiled Fri, 16 Sep 2011 13:48:46 GMT from
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
      'compare@href': function(element) {
        if (this.comparison_url) {
          return this.comparison_url;
        } else {
          element.hide();
          return "";
        }
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