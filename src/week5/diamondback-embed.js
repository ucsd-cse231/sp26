function update() {
  const program = program_box.value;
  const input = input_box.value;
  try {
    let result = interpreter.run(program, input);
    result_box.classList.remove('err');
    result_box.value = result;
  } catch (e) {
    // Ugh hacky
    e = JSON.stringify(e);
    let err;
    if (e.includes('Syntax'))
      err = "Compile-time error (syntax related)";
    else if (e.includes('BadProgram'))
      err = "Compile-time error";
    else if (e.includes('Type'))
      err = "Runtime error (type related)";
    else if (e.includes('Overflow'))
      err = "Runtime error (overflow related)";
    else if (e.includes('Input'))
      err = "Invalid input";
    else
      throw e;

    result_box.classList.add('err');
    result_box.value = err;
  }
}

const div = document.getElementById('embed');
div.innerHTML = `
<style>
.err {
  font-weight: bold;
  color: #d00;
}
</style>
<p><button onclick="update()">Run</button></p>
<p>Input: <input type=text id=input value="7"></p>
<p>
  Program: <br>
  <textarea id=program rows=5 cols=52>(fun (double x) (+ x x))

(double input)
</textarea>
</p>
<p>
  Result: <br>
  <textarea id=result disabled=true cols=52></textarea>
`;

var program_box = document.getElementById('program');
var input_box = document.getElementById('input');
var result_box = document.getElementById('result');
