$(function () {
    var chart;
    var first = null;

    $(document).ready(function() {
    
        // define the options
        var options = {
    
            chart: {
                renderTo: 'container'
            },
    
            title: {
                text: 'User Job Counts by Month'
            },

            xAxis: {
                type: 'datetime',
                gridLineWidth: 1,
		minRange: 0
            },


	    yAxis: {
		title: {
		    text: "Jobs"
		}
	    },
            plotOptions: {
                series: {
                    cursor: 'pointer',
                    point: {
                        events: {
                            click: function() {
                                hs.htmlExpand(null, {
                                    pageOrigin: {
                                        x: this.pageX,
                                        y: this.pageY
                                    },
                                    headingText: this.series.name,
                                    maincontentText: Highcharts.dateFormat('%A, %b %e, %Y', this.x) +':<br/> '+
                                        this.y +' visits',
                                    width: 200
                                });
                            }
                        }
                    },
                    marker: {
                        lineWidth: 1
                    }
                }
            },
  
            series: [{
                name: 'Job Count',
                lineWidth: 4,
                marker: {
                    radius: 4
                }
            }]
        };
    
    
        // Load data asynchronously using jQuery. On success, add the data
        // to the options and initiate the chart.
        // This data is obtained by exporting a GA custom report to TSV.
        // http://api.jquery.com/jQuery.get/

	$(".lsf_chart").each(function() {

		$("<input class=\"ui-widget\" type=\"button\" id=\"go\" value=\"go\">").insertAfter($(this));
		$("<select class=\"ui-widget\" id=\"groupby\"><option>month</option><option selected>mday</option></select>").insertAfter($(this));
		$("<select class=\"ui-widget\" id=\"type\"><option>cputime</option><option selected>jobs</option></select>").insertAfter($(this));

		$("<label class=\"ui-widget\" >User name</label><input class=\"ui-widget\" id=\"username\">").insertAfter($(this));
		$("<label class=\"ui-widget\">Labgroup</label><input class=\"ui-widget\" id=\"labgroup\">").insertAfter($(this));
		
		getData();
		
		
		$("#go").click(function() {
			console.log("Click");
			getData();
		    });

		$("#username").bind("keydown",function(event) {
			if ( event.keyCode === $.ui.keyCode.TAB &&
			     $( this ).data( "autocomplete" ).menu.active ) {
			    event.preventDefault();
			}
		    });
		
		/* Helper functions to carry out the autocomplete 
		 * focus  : what happens when the element is focussed
		 * create : initialization function - adds the add page functionality
		 * select : what happens when a menu element is selected
		 * source : fetches the data to populate the menu
		 */
		
		$("#username").autocomplete({
			cacheLength:   10,
			minLength:      0,
			    
			focus:  function()                    { 
			   return false; 
			},

			select: function( event, ui )         { 
			   $(this).val(ui.item.value);
			},
			source: function( request, response ) { 
			    var labgroup = '';
			    if ($("#labgroup").val()) {
				labgroup = $("#labgroup").val();
			    }
			  $.ajax({
					  
			      url:  "username_query.php",
					    
			      data: {
				      labgroup: labgroup,
				      str: request.term
				      },

			       success: function( data ) {

				      var arr  = data.split("\n");

				      arr = $.map(arr,function(item) {
						    
					      return {
						  id:    item,
						  label: item,
						  value: item
					      }
					  });
					        
				      response(arr);
				  }
			      }); 

			}
		    });
		$("#labgroup").autocomplete({
			cacheLength:   10,
			minLength:      0,
			    
			focus:  function()                    { 
			   return false; 
			},

			select: function( event, ui )         { 
			   $(this).val(ui.item.value);
			   $("#username").val("");
			},
			source: function( request, response ) { 
			  $.ajax({
					  
			      url:  "labgroup_query.php",
					    
			      data: {
				      type: "",
				        str: request.term
				      },

			       success: function( data ) {

				      var arr  = data.split("\n");

				      arr = $.map(arr,function(item) {
						    
					      return {
						  id:    item,
						  label: item,
						  value: item
					      }
					  });
					        
				      response(arr);
				  }
			      }); 

			}
		    });
	    });
	function getData() {

	    var user       = '';
	    var labgroup   = '';
	    var groupby    = '';

	    if ($("#username").val()) {
		user = $("#username").val();
	    }
	    if ($("#labgroup").val()) {
		labgroup = $("#labgroup").val();
	    }
	    if ($("#groupby").val()) {
		groupby = $("#groupby").val();
	    }

	    if (!first) {
		params = getParameters();
		user = params['user'];
		labgroup = params['labgroup'];
		groupby  = params['groupby'];
		first = 1;
	    }
	    console.log("User",user,labgroup,groupby);
	    var jobdata = [];

	    var url = 'lsf_query.php?user='+user+"&groupby="+groupby+"&labgroup="+labgroup;

	    console.log("URL",url);

	    jQuery.get(url, null, function(tsv, state, xhr) {
		    var lines = [];
		    var date;
		    var count;
		    
		    
		    // inconsistency
		    if (typeof tsv !== 'string') {
			tsv = xhr.responseText;
		    }
		    
		    // split the data return into lines and parse them
		    tsv = tsv.split(/\n/g);
		    
		    var i = 0;
		    jQuery.each(tsv, function(i, line) {
			    
			    line  = line.split(/\t/);
			    date  = Date.parse(line[0] +' UTC');;
			    count = parseInt(line[1]);
			    
			    
			    jobdata.push([
					  date,
					  count
					  ]);
			    i++;
			});
		    
		    options.series[0].data = jobdata;
		    options.title = {text: "LSF Jobs"}
		    chart = new Highcharts.Chart(options);
		    console.log(jobdata);
		    return jobdata;
		});
	    
	}
	function getParameters() {
	    var searchString = window.location.search.substring(1)
		, params = searchString.split("&")
		, hash = {}
	    ;
	    
	    for (var i = 0; i < params.length; i++) {
		var val = params[i].split("=");
		hash[unescape(val[0])] = unescape(val[1]);
	    }

	    var user    = $("#username").val();
	    var group   = $("#labgroup").val();
	    var groupby = $("#groupby").val();

	    hash['user'] = user;
	    hash['group'] = group;
	    hash['groupby'] = groupby;

	    return hash;
	} 
	});
    });

