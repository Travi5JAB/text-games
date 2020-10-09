function fullScreen() {
  var element = document.getElementById("iframe");
  if(element.classList == 'not_full'){
    document.getElementById('full_screen').innerHTML = "Exit Full"
    var scroll = document.querySelector("#iframe");
    scroll.scrollIntoView();
    element.classList.remove("not_full");
    element.classList.add("full_screen");
  }else{
    document.getElementById('full_screen').innerHTML = "Full Screen"
    const full = 'Full Screen'
    var scroll = document.querySelector("#main");
    scroll.scrollIntoView();
    element.classList.remove("full_screen");
    element.classList.add("not_full");
  }
}
