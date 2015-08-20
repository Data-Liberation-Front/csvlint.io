//= require jquery
$(document).ready(function () {
  var ToC =
    "<nav role='navigation' class='table-of-contents'>" +
      "<h2>Contents:</h2>" +
      "<ul>";

  var newLine, el, title, link;

  $("h2").each(function() {

    el = $(this);
    title = el.text();
    link = "#" + el.attr("id");

    newLine =
      "<li>" +
        "<a href='" + link + "'>" +
          title +
        "</a>" +
      "</li>";

    ToC += newLine;

  });

  ToC +=
     "</ul>" +
    "</nav>";

  $(".all-questions").prepend(ToC);
});
