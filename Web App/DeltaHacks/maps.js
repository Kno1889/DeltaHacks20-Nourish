let G, options, spans; 
document.addEventListener('DOMContentLoaded', init);

function init(){
    if(navigator.geolocation){
        let giveUp = 30* 1000; // 30 seconds
        let tooOld = 1000 * 60 * 60; // a hour
        
        options = {
            enableHighAccuracy: true, // good but drains battery 
            
            timeout: giveUp, // how long to try contacting the cell towers before giving up 
            maximumAge: tooOld // How long data is valid for
        }
        
        navigator.geolocation.getCurrentPosition(initMap, posFail, options);
    }else{
        // using an old browser that doesn't support geolocation
    }
}

function posFail(err){
    // errors are numbers
    let errors = {
    1: 'no permission',
    2: 'unable to determine',
    3: 'Took too long'
    }
    document.querySelector('h1').textContent = errors[err];
}        

var map;
function initMap(position) {
        map = new google.maps.Map(document.getElementById('map'), {
          center: {lat: position.coords.latitude, lng: position.coords.longitude},
          zoom: 15
        });
        dropPin();
        getAddress();
      }

function dropPin(){
        endMarker = new google.maps.Marker({
            position: map.getCenter(), 
            map: map, 
            draggable: true, // should be false for suppliers, true for receivers 
        });
    }
function getAddress(position){
  // reverse geoloc to get address, filter data
    let x = position.coords.latitude;
    let y = position.coords.longitude;
    
    let url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng={x},{y}&key={AIzaSyCKnZPCIrmK4DpKsmRR9hPtcc98D4nhgMI}';
    
    fetch(url);
    response => response.json() 
    then(data =>{
        console.log(data);
    })
    .catch(err => console.warn(err.message));
}
