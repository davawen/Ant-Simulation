function collision_line_point(x1/*: number*/, y1/*: number*/, x2/*: number*/, y2/*: number*/, obj/*: (object|instance)*/, prec/*: bool*/, notme/*: bool*/)
{
    var rr = collision_line(x1, y1, x2, y2, obj, prec, notme),
        rx = x2,
        ry = y2;
        
    if(rr != noone) {
        var p0 = 0;
        var p1 = 1;
        repeat(ceil(log2(point_distance(x1, y1, x2, y2))) + 1)
        {
            var np = p0 + (p1 - p0) * 0.5;
            var nx = x1 + (x2 - x1) * np;
            var ny = y1 + (y2 - y1) * np;
            var px = x1 + (x2 - x1) * p0;
            var py = y1 + (y2 - y1) * p0;
            var nr = collision_line(px, py, nx, ny, obj, prec, notme);
            if (nr != noone)
            {
                rr = nr;
                rx = nx;
                ry = ny;
                p1 = np;
            }
            else p0 = np;
        }
    }
    var r = {
        inst: rr,
        x: rx,
        y: ry
    };
    return r;
}

function angleDifference(src/*: number*/, dest/*: number*/)/*->number*/
{
    var phi = abs(dest - src) % (pi*2);       // This is either the distance or 360 - distance
    var distance = phi > pi ? (pi*2) - phi : phi;
    
    var s = (src - dest >= 0 && src - dest <= pi) || (src - dest <= -pi && src - dest>= -(pi*2)) ? 1 : -1;
    
    return distance*s;
}


//from -1 to 1
function random_gaussian(stretch/*: number*/)/*->number*/
{
    var _r = random_range(-1, 1);
    
    return (1 - _r*_r*_r - 1)*stretch;
}

function pseudo_random(seed/*: number*/)/*->number*/
{
    return frac(sin(seed)*100000.9752);
}

function foreach(arr, callback, args/*: any?*/)
{
    if (args == undefined) args = [];
    
    var l = array_length(arr);
    for(i = 0; i < l; i++)
    {
        callback(arr[i], i, args);
    }
}

function mostly(a/*: number*/, b/*: number*/, c/*: number*/)/*->int*/
{
    if(a > b && a > c) return 0;
    if(b > a && b > c) return 1;
    if(c > a && c > b) return 2;
    return 3;
}