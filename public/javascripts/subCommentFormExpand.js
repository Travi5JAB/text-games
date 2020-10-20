function replyExpand(){
  var elements = document.getElementsByClassName("sub_comment_form");
  $('.reply').each(function(i) {
    $(this).on('click', function() {
      for(let ei=0; ei<elements.length; ei++){
        if (ei == i) {
          elements[ei].removeAttribute('id')
          elements[ei].id = 'scf_full'
          console.log(elements[ei].id + i + ei);
        }else{
          elements[ei].removeAttribute('id')
          elements[ei].id = 'scf_collapse'
        }
      }
    });
  });
}
