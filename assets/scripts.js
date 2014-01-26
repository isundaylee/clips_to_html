function toggle(id) {
  var d = document.getElementById(id);

  d.style.display = (d.style.display == 'none' || d.style.display == '') ? 'block' : 'none';
}

function show(id) {
  var d = document.getElementById(id)

  if (d) d.style.display = 'block';
}

function hide(id) {
  var d = document.getElementById(id);

  if (d) d.style.display = 'none';
}

function show_all() {
  for (var i=0; i<7; i++) show('week' + i);
}

function hide_all() {
  for (var i=0; i<7; i++) hide('week' + i);
}

function toggle_all() {
  var flag = false;

  for (var i=0; i<7; i++) {
    var d = document.getElementById('week' + i);

    if (d) flag = (flag || (d.style.display != 'none' && d.style.display != ''));
  }

  flag ? hide_all() : show_all();
}
