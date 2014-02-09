
require('cloud/app.js');
	
Parse.Cloud.define("saveListing", function(request, response)
{
    var self    = this;
	this.params = request.params;
	
	this.submitterID  		= request.params.submitterID;
	this.submitterObjectId  = request.params.submitterObjectId;
	this.unit 		  = request.params.unit;
    this.neighborhood = request.params.neighborhood;
	this.monthlyCost  = request.params.monthlyCost;
	this.moveInCost   = request.params.moveInCost;
	this.brokerfee    = request.params.brokerfee;
	this.moveInDate   = request.params.moveInDate;
	this.share        = ( request.params.share == 0) ? false : true;
	this.bedrooms     = request.params.bedrooms;
	this.bathrooms    = request.params.bathrooms;
	this.dogs    	  = ( request.params.dogs == 0 ) ? false : true;
	this.cats    	  = ( request.params.cats == 0 ) ? false : true;
	this.outdoorSpace = ( request.params.outdoorSpace == 0 ) ? false : true;
	this.washerDryer  = ( request.params.washerDryer == 0 ) ? false : true;
	this.gym	      = ( request.params.gym == 0 ) ? false : true;
	this.doorman      = ( request.params.doorman == 0 ) ? false : true;
	this.pool         = ( request.params.pool == 0 ) ? false : true;
	this.keywords     = request.params.keywords;
	this.listingState = request.params.listingState;
	this.long         = request.params.long;
	this.lat          = request.params.lat;
	this.phone   	  = request.params.phone;
	this.email 	  	  = request.params.email;
	
	this.borough      = request.params.borough;
	this.street       = request.params.street;
	this.neighborhood = request.params.neighborhood;
	this.city         = request.params.city;
	this.state        = request.params.state;
	this.zip		  = request.params.zip;
	
	
    var query = new Parse.Query("Listing");
    query.equalTo( "street", request.params.street );
	query.equalTo( "unit", request.params.unit );
    
    query.find(
    {
        success: function(results){ checkExistComplete(results); },
        error: function(error){ response.error( { "code": 1, "data":"service failed to run match" }); }
    });
           
                   
    function checkExistComplete(obj)
    {
        if( obj != null && obj.length > 0 )
        {
            response.error(  { "code": 0, "data":obj } );
        }
        else
        {
            save();
        }
    }
	
	
                   
    function save()
    {
        var Listing = Parse.Object.extend("Listing");
		var listing = new Listing();
		
		if( this.long && this.lat )
		{
			var geo = new Parse.GeoPoint({latitude:this.lat, longitude:this.long});	
			listing.set( "location" , geo );
		}
		

		listing.set( "neighborhood" , this.neighborhood );
		listing.set( "monthlyCost" , this.monthlyCost );
		listing.set( "moveInCost" , this.moveInCost );
		listing.set( "brokerfee" , this.brokerfee );
		listing.set( "moveInDate" , this.moveInDate );
		listing.set( "share" , this.share );
		listing.set( "bedrooms" , this.bedrooms );
		listing.set( "bathrooms" , this.bathrooms );
		listing.set( "dogs" , this.dogs );
		listing.set( "cats" , this.cats );
		listing.set( "outdoorSpace" , this.outdoorSpace );
		listing.set( "washerDryer" , this.washerDryer );
		listing.set( "gym" , this.gym );
		listing.set( "doorman" , this.doorman );
		listing.set( "pool" , this.pool );
		listing.set( "listingState", this.listingState );
		listing.set( "unit", this.unit );
		listing.set( "submitterID", this.submitterID );
		listing.set( "submitterObjectId", this.submitterObjectId );
		listing.set( "keywords", this.keywords );
		listing.set( "isFeatured", false );
		
		listing.set( "phone", this.phone );
		listing.set( "email", this.email );
		
		
		listing.set( "borough", this.borough );
		listing.set( "street", this.street );
		listing.set( "neighborhood", this.neighborhood );
		listing.set( "city", this.city );
		listing.set( "state", this.state  );
		listing.set( "zip", this.zip );
		
        listing.save( null, {
  			success: function(listing) {
				sendEmail(listing);
  		   		response.success( { "code":2, "data" : listing } );
		  	},
  			error: function(listing, error) {
				response.error(  { "code":1, "data":error } );
			}
		});
    }
	
	function sendEmail( listing )
	{
		var params 	  = {};
		params.method  = "POST";
		
		params.headers =  
		{
			'Content-Type': 'application/x-www-form-urlencoded'
		};
		
		params.url     = "http://virtualrealtynyc.com/notification.php";
		params.body    = { "listing" :  listing.id };
		
		console.log( "Trying to send email for listing " + listing + " , objectId : " + listing.id );
		
		params.success = function(httpResponse)
		{
			response.success( httpResponse );	
		};
		
		params.error = function(httpResponse)
		{
			response.error( "error admin failed " + request.params.objectId );	
		};
			
		Parse.Cloud.httpRequest( params );
     } 
		
});

Parse.Cloud.define( "notifyAdmin", function(request, response) 
{
	var params 	  = {};
	params.method  = "POST";
	
	params.headers =  
	{
   		'Content-Type': 'application/x-www-form-urlencoded'
 	};
	
	params.url     = "http://virtualrealtynyc.com/notification.php";
	params.body    = { "listing" :  request.params.objectId };
	
	params.success = function(httpResponse)
	{
		response.success( httpResponse );	
	};
	
	params.error = function(httpResponse)
	{
		response.error( "error admin failed " + request.params.objectId );	
	};
	
	Parse.Cloud.httpRequest( params );
});



Parse.Cloud.define("getListingsForUser", function(request, response)
{
	this.userID = request.params.userID;

	var Listing = Parse.Object.extend("Listing");
	var query = new Parse.Query( Listing );
	query.equalTo( "submitterObjectId", this.userID );
	
	query.find({
		success: function(results) 
		{
			response.success( results );		
	    },
		error: function(error) 
		{
   			alert("Error: " + error.code + " " + error.message);
  		}
	});
});


Parse.Cloud.define("getFeaturedListings", function(request, response)
{

	var Listing = Parse.Object.extend("Listing");
	var query = new Parse.Query( Listing );
	query.equalTo( "listingState", 1 );
	query.equalTo( "isFeatured", true );

	query.descending("createdAt");
	
	query.find({
		success: function(results) 
		{
			response.success( results );		
	    },
		error: function(error) 
		{
   			alert("Error: " + error.code + " " + error.message);
  		}
	});
	
});




Parse.Cloud.define("deleteListing", function(request, response)
{
	console.log( "Trying to delete listing " + request.params.objectId );
	
	var Listing      = Parse.Object.extend("Listing");
	var ListingVideo = Parse.Object.extend("ListingVideo");
	var ListingImage = Parse.Object.extend("ListingImage");
	
	var query  	   = new Parse.Query(Listing);
	var queryVideo = new Parse.Query(ListingVideo);
	var queryImage = new Parse.Query(ListingImage);
	
	queryVideo.equalTo("listingID", request.params.objectId);
	queryImage.equalTo("listingID", request.params.objectId);
	
	console.log( "Trying to delete listing " + request.params.objectId );
	
	
	query.get( request.params.objectId , {
		success: function( listing ){
			listingLoaded( listing );
		},
		error: function(){
			response.error("failed getting image");	
		}
	});
	
	
	
	queryVideo.find( {
		success: function( array )
		{
			console.log( "Loaded video  " + array[0] );
			videoLoaded( ( array.length > 0) ? array[0] : null );
		},
		error: function()
		{

		}
	});
	
	function videoLoaded(video)
	{
		if( video )
		{
			video.destroy(
			{
				success:function(){
				},
				error:function(){
				}	
			});	
		}
	}
	
	queryImage.find( {
		success: function( array )
		{
			imageLoaded(  ( array.length > 0)  ? array[0] : null );
		},
		error: function(){
		
		}
	});
	
	function imageLoaded(img)
	{
		if( img ) 
		{
			img.destroy(
			{
				success:function(){
				},
				error:function(){
				}	
			});	
		}		
	}
	
	function listingLoaded( listing ) 
	{
		listing.destroy({
			success:function(){
				response.success(1);	
			},
			error:function(){
				response.error("failed deleting image");		
			}	
		});	
	}
	
});

Parse.Cloud.define("allListings", function(request, response)
{
	var Listing = Parse.Object.extend("Listing");
	var query = new Parse.Query( Listing );
	query.equalTo( "listingState", 1 );

	query.descending("createdAt");
	
	query.find({
		success: function(results) 
		{
			response.success( results );		
	    },
		error: function(error) 
		{
   			alert("Error: " + error.code + " " + error.message);
  		}
	});
});

Parse.Cloud.define("nearMe", function(request, response)
{
	var Listing = Parse.Object.extend("Listing");
	var query = new Parse.Query( Listing );
	
	var dist = request.params.distance;
	var loc = new Parse.GeoPoint( request.params.latt, request.params.long );
	query.withinMiles("location", loc, dist);
	query.equalTo( "listingState", 1 );
	
	console.log( request.params.long +" : "+ request.params.latt );
	
	query.find({
		success: function(results) 
		{
			response.success( results );		
	    },
		error: function(error) 
		{
   			alert("Error: " + error.code + " " + error.message);
  		}
	});
});


Parse.Cloud.define("search", function(request, response)
{
	var Listing = Parse.Object.extend("Listing");
	var query   = new Parse.Query(Listing);
	query.equalTo( "listingState", 1 );
	
	if( request.params.distance != undefined )
	{
		var dist = request.params.distance;
		var loc = new Parse.GeoPoint( request.params.latt, request.params.long );
		query.withinMiles("location", loc, dist);
	}
	
	if( request.params["filters"] != undefined )
	{
		var minPrice = (request.params.filters["minCost"] != undefined) ? request.params["filters"]["minCost"]["value"] : null;
		var maxPrice = (request.params.filters["maxCost"] != undefined) ? request.params["filters"]["maxCost"]["value"] : null;
		
		
		if( minPrice != null )
		{
			console.log( "Searching min price ------ " + minPrice );
			query.greaterThanOrEqualTo("monthlyCost", minPrice );	
		}
		
		if( maxPrice != null )
		{
			console.log( "Searching max price -------- " + maxPrice );
			query.lessThanOrEqualTo("monthlyCost", maxPrice );	
		}
	
		if( request.params["filters"]["borough"] != undefined )
		{
			query.equalTo( "borough", request.params["filters"]["borough"]["value"].toString() );
		}
		
		if( request.params["filters"]["neighborhood"] != undefined )
		{
			query.equalTo( "neighborhood", request.params["filters"]["neighborhood"]["value"].toString() );
		}
	
		if( request.params["filters"]["state"] != undefined )
		{
			query.equalTo( "state", request.params["filters"]["state"]["value"].toString() );
		}
		
		if( request.params["filters"]["city"] != undefined )
		{
			query.equalTo( "city", request.params["filters"]["city"]["value"].toString() );

		}
		if( request.params["filters"]["bedrooms"] != undefined )
		{
			query.equalTo( "bedrooms", request.params["filters"]["bedrooms"]["value"].toString() );
		}
		if( request.params["filters"]["bathrooms"] != undefined )
		{
			query.equalTo( "bathrooms", request.params["filters"]["bathrooms"]["value"].toString() );
		}
		if( request.params["filters"]["share"] != undefined )
		{
			query.equalTo( "share",   request.params.filters.share.value);
		}
		
		if( request.params["filters"]["dogs"] != undefined )
		{
			query.equalTo( "dogs",   request.params.filters.dogs.value);
		}
		
		if( request.params["filters"]["brokerfee"] != undefined )
		{
			if( request.params.filters.brokerfee.value == true )
			{
				query.lessThanOrEqualTo("brokerfee", 0);		
			}
		}
		
		
		if( request.params["filters"]["cats"] != undefined )
		{
			query.equalTo( "cats",   request.params.filters.cats.value);
		}
		
		if( request.params.filters.outdoorSpace != undefined )
		{
			query.equalTo( "outdoorSpace",   request.params.filters.outdoorSpace.value);
		}
		
		if( request.params.filters.washerDryer != undefined )
		{
			query.equalTo( "washerDryer",   request.params.filters.washerDryer.value);
		}
		
		if( request.params.filters.doorman != undefined )
		{
			query.equalTo( "doorman",   request.params.filters.doorman.value);
		}
		
		if( request.params.filters.pool != undefined )
		{
			query.equalTo( "pool",   request.params.filters.pool.value);
		}
		
		if( request.params.filters.gym != undefined )
		{
			query.equalTo( "gym",   request.params.filters.gym.value);
		}
	}
	
	
	query.descending("createdAt");
	
	
	console.log( "Searching with :---------------------  "  ); 
	
	for( var string in query.toJSON() )
	{
		console.log( "key : " + string + " value : " +  query.toJSON()[string] );
		for( var key in query.toJSON()[string] )
		{
			console.log( "    sub key : " + string + " value : " +  query.toJSON()[string][key] ); 
		}
	}
	
	console.log( "End Searching with :---------------------  "  ); 
	
	query.find({
		success: function(results) 
		{
			response.success( results );		
	    },
		error: function(error) 
		{
   			alert("Error: " + error.code + " " + error.message);
  		}
	});
	
});