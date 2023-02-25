# html_js_4_fun_slid3r
HTML Slider first used for ESP32 and remote car panel. To control car turns and moves.. 


# Example:
https://codepen.io/bla-kos/full/PoeBPNN

# Example of initialization:
```
  var slider = (new Slid3r({
        doubleside:true,
        element   :document.querySelector(".slider.hor .field"),
        onscroll  :function(H) {
            document.querySelector(".slider.hor .info").innerText = H.getResult()+" speed.";
        },
    }));
```

# Required html:
```
<div class="slider hor"> <!-- 
                              To have vertical slide instead of .hor use .ver 
                              To change size of slide do it in slid3r_style.css and lines:
                                 .slider.hor .field { width:200px; } 
                                 .slider.ver .field { height:200px; }
                              Maybe with this will need to be adjust lines:
                                .slider.hor .space { width:400%; }
                                .slider.ver .space { width:400%; }
                         -->
    <div>
        <div class="field scrollit">
            <div class="cover"></div>
            <div class="space"></div>
            <div class="info"></div>
        </div>
    </div>
</div>
```

# Slider options:
  - element    ( required - define slider element Ex. css: ".slider.hor .field"   or   ".slider.ver .field"
  - mobile     ( if mobile=true then "touch" events are used else "mouse" )
  - vertical   ( if slide is used verticaly this should be "true" )
  - doubleside ( if center of slide should be 0 and ends maximum value. (Positive or Negative can be result. Depend on side) )
  - maxresult  ( define maximum value of scroll when scrolled to the end. Default 255 )
  - onscroll   ( function when scroll change is fired )
  - onstart    ( function when user start scrolling is fired )
  - onend      ( function when user removes finger is fired )
  - onended    ( function when user removes finger and scroll gets back to zero is fired )

# Donate - Welcome - Thanks!
<a href="https://www.paypal.com/donate/?hosted_button_id=QGRYL4SL5N4FE"> Donate - Donar - Spenden - Daruj - пожертвовать - दान करना - 捐 - 寄付</a>
