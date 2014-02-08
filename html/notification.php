<?php

$listingID = $_POST['listing'];

mail( "chrisshanley@gmail.com, gabrielberlind@gmail.com, virtualrealty.dev@gmail.com", "VR NYC ADMIN : New Listing Notification", "Listing " . $listingID . " has been submitted for content review.");
 

if( is_null( $listingID ) )
{
	echo( "failed" );
}
else
{
	echo( "success" );
}




?>
