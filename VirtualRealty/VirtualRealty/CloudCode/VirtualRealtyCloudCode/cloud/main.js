Parse.Cloud.define("saveListing", function(request, response)
{
    var self    = this;
	this.params = request.params;
	
	this.submitterID  = request.params.submitterID;
	this.unit 		  = request.params.unit;
    this.address      = request.params.address;
    this.neighborhood = request.params.neighborhood;
	this.monthlyCost  = request.params.monthlyCost;
	this.moveInCost   = request.params.moveInCost;
	this.brokerfee    = ( request.params.brokerfee == 0 ) ? false : true;
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
	this.listingState = request.params.listingState;

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
	query.equalTo( "submitterID", this.userID );
	
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



