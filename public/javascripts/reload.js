function loadlink(){
    $('#comments_area').load(':partial => "pages/comments"',function () {
         $(this).unwrap();
    });
}

loadlink();

// 30000 -> set to 30 seconds
setInterval(function(){
    loadlink()
    // console.log("seconds passed");
}, 60000);
