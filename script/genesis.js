<script>    cA = [];
cH = [];
  window.onload = function() {
   for (let x = 0; x < 1023; x++) {

    let ele = document.getElementsByTagName("p")[x];
		cA.push(ele.getAttribute("class"));
    cH.push(ele.h);
    }
    resetTime();
}


function resetTime() {
    for (let y = 0; y < 1023; y++) {
		let ele = document.getElementsByTagName("p")[y];
    ele.setAttribute("class", cA[y]);
    ele.h = cH[y];
    }
    let time = new Date();
    let hour = (time.getHours() + 24) % 12 || 12;
    let min = time.getMinutes();
    let sec = time.getSeconds();
    hour = hour < 10 ? "0" + hour : hour;
    min = min < 10 ? "0" + min : min;
    sec = sec < 10 ? "0" + sec : sec;
    let currentTime = hour + "" + min;
    var zero = [0, 1, 2, 3, 4, 32, 36, 64, 68, 96, 100, 128, 132, 160, 164, 192, 196, 224, 228, 256, 257, 258, 259, 260, 0, 0, 0, 0];
    
    var one = [2, 34, 66, 98, 130, 162, 194, 226, 258, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
    
    var two = [0, 1, 2, 3, 4, 36, 68, 100, 132, 131, 130, 129, 128, 160, 192, 224, 256, 257, 258, 259, 260, 0, 0, 0, 0, 0, 0, 0];
    
    var three = [0, 1, 2, 3, 4, 36, 68, 100, 132, 131, 130, 129, 128, 164, 196, 228, 256, 257, 258, 259, 260, 0, 0, 0, 0, 0, 0, 0];
    
    var four = [0, 4, 32, 64, 96, 36, 68, 100, 132, 131, 130, 129, 128, 164, 196, 228, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    
     var five = [0, 1, 2, 3, 4, 32, 64, 96, 132, 131, 130, 129, 128, 164, 196, 228, 256, 257, 258, 259, 260, 0, 0, 0, 0, 0, 0, 0];
     
     var six = [0, 32, 64, 96, 132, 131, 130, 129, 128, 160, 164, 192, 196,224,  228, 256, 257, 258, 259, 260, 0, 0, 0, 0, 0, 0, 0, 0];
     
      var seven = [0, 1, 2, 3, 4, 36, 68, 100, 132, 164, 196, 228, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
     
     var eight = [0, 1, 2, 3, 4, 32, 36, 64, 68, 96, 100, 128, 132,131, 130, 129, 128, 160, 164, 192, 196, 224, 228, 256, 257, 258, 259, 260];
    
     var nine = [0, 1, 2, 3, 4, 32, 64, 96, 36, 68, 100, 132, 131, 130, 129, 128, 164, 196, 228, 260, 0, 0, 0, 0, 0, 0, 0, 0];
    
    var db = [zero, one, two, three, four, five, six, seven, eight, nine]
    var t1 = parseInt(currentTime.charAt(0))
   	var t2 = parseInt(currentTime.charAt(1))
    var t3 = parseInt(currentTime.charAt(2))
    var t4 = parseInt(currentTime.charAt(3))
    
    for(let d = 0; d < 28; d++) {
    let a1 = document.getElementsByTagName("p")[356 + db[t1][d]];
    a1.setAttribute("class", "f");
    a1.h = 1;
     let a2 = document.getElementsByTagName("p")[362 + db[t2][d]];
    a2.setAttribute("class", "f");
    a2.h = 1;
        let a3 = document.getElementsByTagName("p")[369 + db[t3][d]];
    a3.setAttribute("class", "f");
    a3.h = 1;
    
        let a4 = document.getElementsByTagName("p")[375 + db[t4][d]];
    a4.setAttribute("class", "f");
    a4.h = 1;
		}   
}

    window.setInterval('resetTime()', 10000); 	// Call a function every 10000 milliseconds (OR 10 seconds).
</script>
