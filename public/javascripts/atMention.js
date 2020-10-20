$(function(){
  data = $('.temp_information').data('usernames');
  $('textarea').atwho({at:"@", 'data':data});
});

// validate function - submits a validaiton if a user is @mentioned
function validate(){
  data = $('.temp_information').data('usernames');
  commentTxt = $('textarea#comment_ta')
  subCommentTxt = $('textarea#sc_ta')
  ratingTxt =  $('textarea#rating_ta')

  if (data.some(name => commentTxt.val().includes(name) ) ) {
    txt = commentTxt.val().split(' ')
    for (let i = 0; i < txt.length; i++){
      if (txt[i].includes('@')){
        var mentioned = txt[i].substring(1)
      }
    }
  }else if (data.some(name => subCommentTxt.val().includes(name) )){
    txt = subCommentTxt.val().split(' ')
    for (let i = 0; i < txt.length; i++){
      if (txt[i].includes('@')){
        var mentioned = txt[i].substring(1)
      }
    }
  }else if (data.some(name => ratingTxt.val().includes(name) )){
    txt = ratingTxt.val().split(' ')
    for (let i = 0; i < txt.length; i++){
      if (txt[i].includes('@')){
        var mentioned = txt[i].substring(1)
      }
    }
  }else{
    var mentioned = ""
  }
  // sets value to pass back to controller
  $('input#mentioned').val(mentioned)
}
