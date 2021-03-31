nest = new Nest(rw/2, rh/2, 50, 0);
food = []; /// @is {FoodCluster[]}
for(i = 0; i < 3; i++)
{
    food[i] = new FoodCluster(random(rw), random(rh), irandom(40)+40);
}

ants = []; /// @is {Ant[]}
pheromones = []; /// @is {Pheromone[]}

quad = new Quad(new Rectangle(0, 0, rw, rh), 4, 12); /// @is {Quad}
quadTimer = 60; // Regenerate quadtree every second

pressX = 0;
pressY = 0;

avrFps = 0;

var _s = ds_stack_create(),
    _a = [];
    
var _time = current_time;

for(i = 0; i < 100000; i++)
{
    ds_stack_push(_s, 0);
}

console.log(current_time-_time);

_time = current_time;

for(i = 0; i < 100000; i++)
{
    _a[i] = 0;
}

console.log(current_time-_time);

#region Camera
view_enabled = true;
view_visible[0] = true;

view_camera[0] = camera_create_view(0, 0, 1280, 800);

window_set_size(1280, 800);
surface_resize(application_surface, 1280, 800);

function resize(zoom, ox, oy)
{
    //!#import camera.*
    
    if (ox == undefined) ox = .5;
    if (oy == undefined) oy = .5;
    
    var _w = camera_get_view_width(view_camera[0]),
        _h = camera_get_view_height(view_camera[0]),
        _x = camera_get_view_x(view_camera[0]),
        _y = camera_get_view_y(view_camera[0]);
        
    camera_set_view_pos(view_camera[0], _x + (_w - (_w*zoom))*ox, _y + (_h - (_h*zoom))*oy);
    camera_set_view_size(view_camera[0], _w*zoom, _h*zoom);
}
#endregion