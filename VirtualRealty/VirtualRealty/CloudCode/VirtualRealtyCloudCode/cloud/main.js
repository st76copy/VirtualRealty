Parse.Cloud.define("saveListing", function(request, response)
{
    var self    = this;
	this.params = request.params;
	
	this.submitterID  		= request.params.submitterID;
	this.submitterObjectId  = request.params.submitterObjectId;
	this.unit 		  = request.params.unit;
    this.address      = request.params.address;
    this.neighborhood = request.params.neighborhood;
	this.monthlyCost  = request.params.monthlyCost;
	this.moveInCost   = request.params.moveInCost;
	this.brokerfee    = request.params.brokerfee;
	this.moveInDate   = request.params.moveInDate;
	this.contact      = request.params.contact;
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

    var query = new Parse.Query("Listing");
    query.equalTo( "address", request.params.address );
	query.equalTo( "unit", request.params.unit );
    
    query.find(
    {
        success: function(results){ checkExistComplete(results); },
        error: function(error){ response.error( { "code": 1, "data":error  }); }
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
		
		listing.set( "address" , this.address );
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
		listing.set( "contact", this.contact );
		listing.set( "listingState", this.listingState );
		listing.set( "unit", this.unit );
		listing.set( "submitterID", this.submitterID );
		listing.set( "submitterObjectId", this.submitterObjectId );
		listing.set( "keywords", this.keywords );
		listing.set( "isFeatured", false );
        listing.save( null, {
  			success: function(listing) {
  		   		response.success( { "code":2, "data" : listing } );
		  	},
  			error: function(listing, error) {
				response.error(  { "code":1, "data":error } );
			}
		});
     
    }
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
	console.log( "search ----  " + request.params.filters );
	if( request.params.filters )
	{
		console.log("have filters ");
		var minPrice = (request.params.filters["minCost"] != undefined) ? request.params.filters["minCost"]["value"] : null;
		var maxPrice = (request.params.filters["maxCost"] != undefined) ? request.params.filters["maxCost"]["value"] : null;
	 }
	
	var boolArray = ["share", "dogs", "cats", "outdoorSpace", "washerDryer", "doorman", "pool", "gym"];
	var keyword   = request.params.keyword;
	
	if( keyword )
	{
		query.equalTo( "keywords", keyword );
		console.log( "searching keyword : " + keyword );
	}
	
	if( request.params.filters )
	{
		if( minPrice )
		{
			query.greaterThan("monthlyCost", minPrice);
		}
		
		if( maxPrice )
		{ 
			query.lessThan("monthlyCost", maxPrice);	
		}
		
		
		for( var key in request.params.filters )
		{
			if( key != "minCost" && key != "maxCost" )
			{
				query.equalTo(key, request.params.filters[key]["value"] );
			}
		}
	}
	
	function contains(key)
	{
		var exists = false;
		var flag;
		
		for(  var i = 0; i < boolArray.count; i ++ )
		{
			flag = boolArray[i];
			if( flag == key )
			{
				exists = true;	
			}
		}
		return exists;
	}
	
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
	
	
	function listingsLoaded( listings ) 
	{

	}
	
});