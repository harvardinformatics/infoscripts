(function($) {

    $.fn.LSFChart = function(options) {

	return this.each(function() {

		if ($(this).data('lsfchart')) {    // Don't init if data object exists
		    return;
		}

		var lsfchart = new LSFChart(this,options);  // Create the data object
		
		$(this).data('lsfchar',lsfchart);  // Attach the data object to the element
		
		//lsfchart.init();                   // Initialize stuff
		
	    });
    }


    var LSFChart = function(element,options) {
	obj = this;

	obj.makeChartOptions();

	console.log(obj.options);
	obj.getData();

	obj.makeChart();
	
    }
    var makeChart = function() {
	
	obj.options.series[0].data = obj.jobdata;
	obj.options.title = {text: "LSF Jobs for user " + user}
	obj.chart = new Highcharts.Chart(obj.options);
    }

    var getData = function() {

	obj.getParameters();

	var user    = '';
	var groupby = '';
	
	if (params['user'])    { user    = params['user'];}
	if (params['groupby']) { groupby = params['groupby'];}
	
	jQuery.get('lsf_query.php?user='+user+"&groupby="+groupby, null, function(tsv, state, xhr) {
		var lines = [];
		var date;
		var count;
		
		obj.jobdata = [];
		
		// inconsistency
		if (typeof tsv !== 'string') {
		    tsv = xhr.responseText;
		}
		
		console.log(tsv);
		
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
		
	    });
    }
   
    var getParameters = function() {
	var searchString = window.location.search.substring(1)
	, params = searchString.split("&")
	, hash = {}
	;
	
	for (var i = 0; i < params.length; i++) {
	    var val = params[i].split("=");
	    hash[unescape(val[0])] = unescape(val[1]);
	}
	return hash;
    } 
    var makeChartOptions = function() {
	var options = {
	    
            chart: {
                renderTo: 'container'
            },
    
            title: {
                text: 'LSF Job Chart'
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

	obj.chartOptions = options;
    }
});
    
